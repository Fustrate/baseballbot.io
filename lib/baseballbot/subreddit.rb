# frozen_string_literal: true

require_relative 'template/base'
require_relative 'template/gamechat'
require_relative 'template/sidebar'

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

      @timezone = begin
        TZInfo::Timezone.get options['timezone']
      rescue TZInfo::InvalidTimezoneIdentifier
        TZInfo::Timezone.get 'America/Los_Angeles'
      end
    end

    def team
      @team ||= @bot.api.team(@team_id) if @team_id
    end

    def code
      team&.abbreviation
    end

    def now
      @now ||= Baseballbot.parse_time(Time.now.utc, in_time_zone: @timezone)
    end

    def post_off_day_thread?
      return false unless @options.dig('off_day', 'enabled')

      url = format(
        'http://statsapi.mlb.com/api/v1/schedule?teamId=%<team_id>d&' \
        'date=%<today>s&sportId=1&eventTypes=primary&scheduleTypes=games',
        team_id: @team_id,
        today: Time.now.strftime('%m/%d/%Y')
      )

      JSON.parse(URI.parse(url).open.read).dig('totalGames').zero?
    end

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

    def subreddit
      @subreddit ||= @bot.session.subreddit(@name)
    end

    def settings
      return @settings if @settings

      @bot.use_account @account.name

      @settings = subreddit.settings
    end

    # Update settings for the current subreddit
    #
    # @param new_settings [Hash] new settings to apply to the subreddit
    def modify_settings(new_settings = {})
      @bot.use_account @account.name

      response = subreddit.modify_settings new_settings

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
      @bot.use_account @account.name

      subreddit.submit title, text: text, sendreplies: false
    end

    def edit(id:, body: nil)
      @bot.use_account @account.name

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

      submission = @bot.session.from_ids("t3_#{id}")&.first

      raise "Unable to load post #{id}." unless submission

      @submissions[id] = submission
    end

    def template_for(type)
      rows = @bot.db.exec_params(
        "SELECT body, title
        FROM templates
        WHERE subreddit_id = $1 AND type = $2",
        [@id, type]
      )

      raise "/r/#{@name} does not have a #{type} template." if rows.count < 1

      [rows[0]['body'], rows[0]['title']]
    end

    def sidebar_template
      body, = template_for('sidebar')

      Template::Sidebar.new body: body, subreddit: self
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
