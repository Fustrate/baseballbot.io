# frozen_string_literal: true

require_relative 'template/base'
require_relative 'template/gamechat'
require_relative 'template/sidebar'

class Baseballbot
  class Subreddit
    attr_reader :account, :name, :team, :timezone, :code

    def initialize(bot:, id:, name:, team_id:, account:, options: {})
      @bot = bot
      @id = id
      @name = name
      @account = account
      @submissions = {}
      @options = options

      @timezone = begin
        TZInfo::Timezone.get options['timezone']
      rescue TZInfo::InvalidTimezoneIdentifier
        TZInfo::Timezone.get 'America/Los_Angeles'
      end

      @team = @bot.api.team(team_id) if team_id
      @code = @team&.abbreviation
    end

    def now
      @now ||= Baseballbot.parse_time(Time.now.utc, in_time_zone: @timezone)
    end

    # !@group Game Chats

    def post_gamechat(id:, title:, game_pk:)
      @bot.use_account(@account.name)

      template = gamechat_template(game_pk: game_pk, title: title)
      submission = submit title: template.title, text: template.result

      # Mark as posted right away so that it won't post again
      change_gamechat_status id, submission, 'Posted'

      raw_markdown = CGI.unescapeHTML(submission.selftext)

      submission.edit raw_markdown.gsub('#ID#', submission.id)

      @bot.redis.hset(template.gid, @name.downcase, submission.id)

      post_process_submission submission, sticky: sticky_gamechats?, sort: 'new'

      set_post_flair submission, @options.dig('gamechats', 'flair', 'default')

      @bot.logger.info "Posted #{submission.id} in /r/#{@name} for #{game_pk}"

      submission
    end

    # Update a gamechat - also starts the "game over" process if necessary
    #
    # @param id [String] The baseballbot id of the gamechat
    # @param game_pk [Integer] The mlb id of the game
    # @param post_id [String] The reddit id of the post to update
    #
    # @return [Boolean] to indicate if the game is over or postponed
    def update_gamechat(id:, game_pk:, post_id:)
      @bot.use_account(@account.name)

      template = gamechat_update_template(post_id: post_id, game_pk: game_pk)
      submission = load_submission(id: post_id)

      edit(
        id: post_id,
        body: template.replace_in(CGI.unescapeHTML(submission.selftext))
      )

      @bot.logger.info "Updated #{submission.id} in /r/#{@name} for #{game_pk}"

      if template.final?
        end_gamechat(id, submission, game_pk)

        if template.won?
          set_post_flair submission, @options.dig('gamechats', 'flair', 'won')
        elsif template.lost?
          set_post_flair submission, @options.dig('gamechats', 'flair', 'lost')
        end
      else
        change_gamechat_status id, submission, 'Posted'
      end

      template.final?
    end

    def end_gamechat(id, submission, game_pk)
      change_gamechat_status id, submission, 'Over'

      post_process_submission(
        submission,
        sticky: sticky_gamechats? ? false : nil
      )

      @bot.logger.info "Ended #{submission.id} in /r/#{@name} for #{game_pk}"

      post_postgame(game_pk: game_pk)
    end

    # !@endgroup

    # !@group Pre Game Chats

    def post_pregame(id:, game_pk:)
      return unless @options.dig('pregame', 'enabled')

      @bot.use_account(@account.name)

      template = pregame_template(game_pk: game_pk)

      submission = submit title: template.title, text: template.result

      change_gamechat_status id, submission, 'Pregame'

      post_process_submission submission, sticky: sticky_gamechats?

      set_post_flair submission, @options.dig('pregame', 'flair')

      @bot.logger.info "Pregame #{submission.id} in /r/#{@name} for #{game_pk}"

      submission
    end

    # !@endgroup

    # !@group Post Game Chats

    # Create a postgame thread if the subreddit is set to have them
    #
    # @param game_pk [String] the MLB game ID
    #
    # @return [Redd::Models::Submission] the postgame thread
    def post_postgame(game_pk:)
      return unless @options.dig('postgame', 'enabled')

      @bot.use_account(@account.name)

      template = postgame_template(game_pk: game_pk)

      submission = submit title: template.title, text: template.result

      post_process_submission submission, sticky: sticky_gamechats?

      set_post_flair submission, @options.dig('postgame', 'flair')

      @bot.logger.info "Postgame #{submission.id} in /r/#{@name} for #{game_pk}"

      submission
    end

    # !@endgroup

    # --------------------------------------------------------------------------
    # Miscellaneous
    # --------------------------------------------------------------------------

    def sticky_gamechats?
      @options.dig('gamechats', 'sticky') != false
    end

    def generate_sidebar
      sidebar_template.replace_in current_sidebar
    end

    def current_sidebar
      raise Baseballbot::Error::NoSidebarText unless settings[:description]

      CGI.unescapeHTML settings[:description]
    end

    # @param id [Integer] the baseballbot ID of the gamechat
    # @param submission [Redd::Models::Submission] the post itself
    # @param status [String] status of the gamechat
    def change_gamechat_status(id, submission, status)
      gamechat_posted = status == 'Posted'

      fields = ['status = $2', 'updated_at = $3']
      fields.concat ['post_id = $4', 'title = $5'] if gamechat_posted

      @bot.db.exec_params(
        "UPDATE gamechats SET #{fields.join(', ')} WHERE id = $1",
        [
          id,
          status,
          Time.now,
          (submission.id if gamechat_posted),
          (submission.title if gamechat_posted)
        ].compact
      )
    end

    def subreddit
      @subreddit ||= @bot.session.subreddit(@name)
    end

    def settings
      return @settings if @settings

      @bot.use_account(@account.name)

      @settings = subreddit.settings
    end

    # Update settings for the current subreddit
    #
    # @param new_settings [Hash] new settings to apply to the subreddit
    def update(new_settings = {})
      @bot.use_account(@account.name)

      response = subreddit.modify_settings(new_settings)

      log_errors response.body.dig(:json, :errors), new_settings
    end

    # Submit a post to reddit in the current subreddit
    #
    # @param title [String] the title of the submission to create
    # @param text [String] the markdown body of the submission to create
    #
    # @return [Redd::Models::Submission] the successfully created submission
    #
    # @todo Restore ability to pass captcha
    def submit(title:, text:)
      @bot.use_account(@account.name)

      subreddit.submit(title, text: text, sendreplies: false)
    end

    def edit(id:, body: nil)
      @bot.use_account(@account.name)

      load_submission(id: id).edit(body)
    end

    # Load a submission from reddit by its id
    #
    # @param id [String] an id to load
    #
    # @return [Redd::Models::Submission] the submission, if found
    #
    # @raise [RuntimeError] if a submission with this id does not exist
    def load_submission(id:)
      return @submissions[id] if @submissions[id]

      @bot.use_account(@account.name)

      submissions = @bot.session.from_ids "t3_#{id}"

      raise "Unable to load post #{id}." unless submissions&.first

      @submissions[id] = submissions.first
    end

    protected

    def post_process_submission(submission, sticky: false, sort: '')
      if submission.stickied
        submission.remove_sticky if sticky == false
      elsif sticky
        submission.make_sticky
      end

      return if sort == ''

      submission.set_suggested_sort sort
    end

    def set_post_flair(submission, flair)
      return unless flair

      subreddit.set_flair submission, flair['text'], css_class: flair['class']
    end

    def sidebar_template
      body, = template_for('sidebar')

      Template::Sidebar.new body: body, bot: @bot, subreddit: self
    end

    def gamechat_template(game_pk:, title:)
      body, default_title = template_for('gamechat')

      title = title && !title.empty? ? title : default_title

      Template::Gamechat.new body: body,
                             bot: @bot,
                             subreddit: self,
                             game_pk: game_pk,
                             title: title
    end

    def gamechat_update_template(game_pk:, post_id:)
      body, = template_for('gamechat_update')

      Template::Gamechat.new body: body,
                             bot: @bot,
                             subreddit: self,
                             game_pk: game_pk,
                             post_id: post_id
    end

    def pregame_template(game_pk:)
      body, title = template_for('pregame')

      Template::Gamechat.new body: body,
                             bot: @bot,
                             subreddit: self,
                             game_pk: game_pk,
                             title: title
    end

    def postgame_template(game_pk:)
      body, title = template_for('postgame')

      Template::Gamechat.new body: body,
                             bot: @bot,
                             subreddit: self,
                             game_pk: game_pk,
                             title: title
    end

    def template_for(type)
      result = @bot.db.exec_params(
        "SELECT body, title
        FROM templates
        WHERE subreddit_id = $1 AND type = $2",
        [@id, type]
      )

      raise "/r/#{@name} does not have a #{type} template." if result.count < 1

      [result[0]['body'], result[0]['title']]
    end

    # --------------------------------------------------------------------------
    # Logging
    # --------------------------------------------------------------------------

    def log_errors(errors, new_settings)
      return unless errors&.count&.positive?

      errors.each do |error|
        @bot.logger.info "#{@name}: #{error[0]}: #{error[1]} (#{error[2]})"

        next unless error[0] == 'TOO_LONG' && error[1] =~ /max: \d+/

        # TODO: Message the moderators of the subreddit to tell them their
        # sidebar is X characters too long.
        puts "New length is #{new_settings[error[2].to_sym].length}"
      end
    end
  end
end
