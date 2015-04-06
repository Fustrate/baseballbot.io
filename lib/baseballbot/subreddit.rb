class Baseballbot
  class Subreddit
    attr_reader :account, :name, :team, :time, :code

    def initialize(bot:, id:, name:, code:, account:, options: {})
      @bot = bot
      @id = id
      @name = name
      @account = account
      @submissions = {}
      @options = options
      @code = code

      @time = begin
        TZInfo::Timezone.get options['timezone']
      rescue TZInfo::InvalidTimezoneIdentifier
        TZInfo::Timezone.get 'America/Los_Angeles'
      end

      @team = @bot.gameday.team(@code) if @code
    end

    def sticky_gamechats?
      @options['gamechats']['sticky'] != false
    end

    def client
      @client ||= @bot.clients[@account.name].tap do |c|
        c.access = @account.access
        c.refresh_access! if @account.access.expired?
      end
    end

    def generate_sidebar
      sidebar_template.replace_in current_sidebar
    end

    def current_sidebar
      CGI.unescapeHTML settings[:description]
    end

    def post_gamechat(gid:)
      template = gamechat_template(gid: gid)

      submit template.title, text: template.result, sticky: sticky_gamechats?
    end

    def post_postgame(gid:)
      template = postgame_template(gid: gid)

      submit template.title, text: template.result, sticky: sticky_gamechats?
    end

    def update_gamechat(gid:, post_id:)
      template = gamechat_update_template(gid: gid, post_id: post_id)

      post = submission(id: post_id)

      fail "Could not load post with ID #{post_id}." unless post

      body = template.replace_in CGI.unescapeHTML(post[:selftext])

      if template.game.over?
        edit(id: post_id, body: body, sticky: sticky_gamechats? ? false : nil)

        if @options['postgame'] && @options['postgame']['enabled']
          post_postgame(gid: gid)
        end
      else
        edit(id: post_id, body: body)
      end

      template.game.over?
    end

    def settings
      @settings ||= client.subreddit_from_name(@name).to_h
    end

    def update(new_settings = {})
      response = client.subreddit_from_name(@name).admin_edit(new_settings)

      log_errors response.body[:json][:errors]
    end

    def log_errors(errors)
      return unless errors && errors.count > 0

      errors.each do |error|
        log "#{error[0]}: #{error[1]} (#{error[2]})"
      end
    end

    # TODO: Make this an actual logger, so we can log to something different
    def log(message)
      puts Time.now.strftime "[%Y-%m-%d %H:%M:%S] #{@name}: #{message}"
    end

    # Returns the post ID
    def submit(title, text:, sticky: false)
      subreddit = client.subreddit_from_name(@name)

      thing = subreddit.submit(title, text: text, sendreplies: false)

      # Why doesn't the redd gem just return a Redd::Objects::Submission?
      post = client.from_fullname(thing[:name]).first

      post.set_sticky if sticky

      post
    end

    def edit(id:, body: nil, sticky: nil)
      return unless body || !sticky.nil?

      post = submission id: id

      post.edit(body) if body

      post.set_sticky if sticky
      post.unset_sticky if sticky == false
    end

    def submission(id:)
      @submissions[id] ||= client.from_fullname("t3_#{id}").first
    end

    protected

    def sidebar_template
      body, _ = template_for('sidebar')

      Template::Sidebar.new body: body,
                            bot: @bot,
                            subreddit: self
    end

    def gamechat_template(gid:)
      body, title = template_for('gamechat')

      Template::Gamechat.new body: body,
                             bot: @bot,
                             subreddit: self,
                             gid: gid,
                             title: title
    end

    def gamechat_update_template(gid:, post_id:)
      body, _ = template_for('gamechat_update')

      Template::Gamechat.new body: body,
                             bot: @bot,
                             subreddit: self,
                             gid: gid,
                             post_id: post_id
    end

    def postgame_template(gid:)
      body, title = template_for('postgame')

      Template::Gamechat.new body: body,
                             bot: @bot,
                             subreddit: self,
                             gid: gid,
                             title: title
    end

    def template_for(type)
      result = @bot.db.exec_params(
        "SELECT body, title
        FROM templates
        WHERE subreddit_id = $1 AND type = $2",
        [@id, type]
      )

      fail "#{@name} does not have a #{type} template." if result.count < 1

      [result[0]['body'], result[0]['title']]
    end
  end
end
