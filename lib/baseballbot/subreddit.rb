# frozen_string_literal: true

class Baseballbot
  class Subreddit
    attr_reader :id, :account, :name, :timezone, :options, :bot

    def initialize(bot:, id:, name:, team_id:, account:, options: {})
      @bot = bot

      @id = id
      @name = name
      @team_id = team_id
      @account = account

      @submissions = {}
      @options = options

      @timezone = parse_timezone options['timezone']
    end

    def team
      @team ||= @bot.api.team(@team_id) if @team_id
    end

    def code
      team&.abbreviation
    end

    def now
      @now ||= Baseballbot::Utility.parse_time(
        Time.now.utc,
        in_time_zone: @timezone
      )
    end

    def log_action(action, note: '', data: {})
      @bot.log_action(
        subject_type: 'Subreddit',
        subject_id: @id,
        action: action,
        note: note,
        data: data
      )
    end

    def post_off_day_thread?
      @bot.api.schedule(
        sportId: 1,
        teamId: @team_id,
        date: Time.now.strftime('%m/%d/%Y'),
        eventTypes: 'primary',
        scheduleTypes: 'games'
      ).dig('totalGames').zero?
    end

    # --------------------------------------------------------------------------
    # Miscellaneous
    # --------------------------------------------------------------------------

    def sticky_game_threads?
      @options.dig('game_threads', 'sticky') != false
    end

    def generate_sidebar
      sidebar_template.replace_in current_sidebar
    end

    def current_sidebar
      unless settings[:description] && !settings[:description].strip.empty?
        raise Baseballbot::Error::NoSidebarText
      end

      CGI.unescapeHTML settings[:description]
    end

    def subreddit
      @subreddit ||= @bot.session.subreddit(@name)
    end

    def settings
      return @settings if @settings

      @bot.with_reddit_account(@account.name) do
        @settings = subreddit.settings
      end
    end

    # Update settings for the current subreddit
    #
    # @param new_settings [Hash] new settings to apply to the subreddit
    def modify_settings(new_settings = {})
      if new_settings.key?(:description)
        raise 'Sidebar is blank.' if new_settings[:description].strip.empty?
      end

      @bot.with_reddit_account(@account.name) do
        response = subreddit.modify_settings(new_settings)

        log_errors response.body.dig(:json, :errors), new_settings

        log_action 'Updated settings', data: new_settings
      end
    end

    # Submit a post to reddit in the current subreddit
    #
    # @param title [String] the title of the submission to create
    # @param text [String] the markdown body of the submission to create
    #
    # @return [Redd::Models::Submission] the successfully created submission
    #
    # @todo Restore ability to pass captcha
    def submit(title:, text:, sendreplies: false)
      @bot.with_reddit_account(@account.name) do
        subreddit.submit title, text: text, sendreplies: sendreplies
      end
    end

    def edit(id:, body: nil)
      @bot.with_reddit_account(@account.name) do
        load_submission(id: id).edit(body)
      end
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

      @bot.with_reddit_account(@account.name) do
        submission = @bot.session.from_ids("t3_#{id}")&.first

        raise "Unable to load post #{id}." unless submission

        @submissions[id] = submission
      end
    end

    def template_for(type)
      rows = @bot.db.exec_params(<<~SQL, [@id, type])
        SELECT body
        FROM templates
        WHERE subreddit_id = $1 AND type = $2
      SQL

      raise "/r/#{@name} does not have a #{type} template." if rows.count < 1

      rows[0]['body']
    end

    def sidebar_template
      Template::Sidebar.new body: template_for('sidebar'), subreddit: self
    end

    # --------------------------------------------------------------------------
    # Logging
    # --------------------------------------------------------------------------

    def log_errors(errors, _new_settings)
      return unless errors&.count&.positive?

      errors.each do |error|
        log_action 'Sidebar update error', data: { error: error }

        # if error[0] == 'TOO_LONG' && error[1] =~ /max: \d+/
        #   # TODO: Message the moderators of the subreddit to tell them their
        #   # sidebar is X characters too long.
        # end
      end
    end

    def parse_timezone(name)
      TZInfo::Timezone.get name
    rescue TZInfo::InvalidTimezoneIdentifier
      TZInfo::Timezone.get 'America/Los_Angeles'
    end
  end
end
