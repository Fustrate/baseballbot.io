class Baseballbot
  class Subreddit
    attr_reader :account, :name, :team

    def initialize(bot:, id:, name:, account:)
      @bot = bot
      @id = id
      @name = name
      @account = account

      code = Baseballbot.subreddit_to_code name

      @team = @bot.gameday.team(code) if code
    end

    def generate_sidebar
      sidebar_template.replace_in current_sidebar
    end

    def current_sidebar
      CGI.unescapeHTML settings[:description]
    end

    def post_gamechat(gid:, title:)
      template = gamechat_template(gid: gid, title: title)

      submit template.title, text: template.result
    end

    def settings
      return @settings if @settings

      @bot.in_subreddit(self) do |client|
        @settings = client.subreddit_from_name(@name).to_h
      end
    end

    def update(new_settings = {})
      @bot.in_subreddit(self) do |client|
        client.subreddit_from_name(@name).admin_edit new_settings
      end
    end

    # Returns the post ID
    def submit(title, text:, sticky: true)
      @bot.in_subreddit(self) do |client|
        subreddit = client.subreddit_from_name(@name)

        thing = subreddit.submit(title, text: text, sendreplies: false)

        # Why doesn't the redd gem just return a Redd::Objects::Submission?
        post = client.from_fullname(thing[:name]).first

        post.set_sticky if sticky

        return post
      end
    end

    def edit(id:, body: nil, sticky: nil)
      @bot.in_subreddit(self) do |client|
        post = client.from_fullname("t3_#{id}")

        post.edit(body) if body

        post.set_sticky if sticky
        post.unset_sticky if sticky == false
      end
    end

    protected

    def sidebar_template
      Template::Sidebar.new body: template_body(type: 'sidebar'),
                            bot: @bot,
                            subreddit: self
    end

    def gamechat_template(gid:, title:)
      Template::Gamechat.new body: template_body(type: 'gamechat'),
                             bot: @bot,
                             subreddit: self,
                             gid: gid,
                             title: title
    end

    def template_body(type:)
      result = @bot.db.exec_params(
        "SELECT body
        FROM templates
        WHERE subreddit_id = $1 AND type = $2",
        [@id, type]
      )

      fail "#{@name} does not have a #{type} template." if result.count < 1

      result[0]['body']
    end
  end
end
