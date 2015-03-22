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

    protected

    def sidebar_template
      Template::Sidebar.new body: template_body(type: 'sidebar'),
                            bot: @bot,
                            subreddit: self
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
