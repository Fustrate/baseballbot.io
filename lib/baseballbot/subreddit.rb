# frozen_string_literal: true
require_relative 'template/base'
require_relative 'template/gamechat'
require_relative 'template/sidebar'

module Redd
  module Objects
    class Submission < Thing
      # suggested_sort should be one of:
      # ['', 'confidence', 'top', 'new', 'hot', 'controversial', 'old',
      # 'random', 'qa']
      def suggested_sort=(suggested_sort)
        post('/api/set_suggested_sort', id: fullname, sort: suggested_sort)
      end

      def flair_template_id=(flair_template_id)
        post('/api/selectflair',
             link: fullname,
             flair_template_id: flair_template_id)
      end
    end
  end

  module Clients
    class Base
      module Read
        def from_fullname(*fnames)
          request_object(:get, "/by_id/#{fnames.join(',')}", {})
        end
      end
    end
  end
end

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
        @bot.refresh_client!(c) if @account.access.expired?
      end
    end

    def generate_sidebar
      sidebar_template.replace_in current_sidebar
    end

    def current_sidebar
      raise Baseballbot::Error::NoSidebarText unless settings[:description]

      CGI.unescapeHTML settings[:description]
    end

    def post_gamechat(gid:, title:, flair: nil)
      template = gamechat_template(gid: gid, title: title)

      post = submit template.title,
                    text: template.result,
                    sticky: sticky_gamechats?,
                    sort: 'new',
                    flair: flair

      @bot.redis.hset template.game.gid,
                      @name.downcase,
                      post[:id]

      post
    end

    def post_pregame(gid:, flair: nil)
      template = pregame_template(gid: gid)

      submit template.title, text: template.result, sticky: sticky_gamechats?, flair: flair
    end

    def post_postgame(gid:, flair: nil)
      template = postgame_template(gid: gid)

      submit template.title, text: template.result, sticky: sticky_gamechats?, flair: flair
    end

    # Returns a boolean to indicate if the game is (effectively) over
    def update_gamechat(gid:, post_id:)
      template = gamechat_update_template(gid: gid, post_id: post_id)

      post = submission(id: post_id)

      raise "Could not load post with ID #{post_id}." unless post

      body = template.replace_in CGI.unescapeHTML(post[:selftext])

      if template.game.over?
        edit(id: post_id, body: body, sticky: sticky_gamechats? ? false : nil)

        if @options['postgame'] && @options['postgame']['enabled']
          post_postgame(gid: gid, flair: @options['postgame']['flair'])
        end
      else
        edit(id: post_id, body: body)
      end

      template.game.over? || template.game.postponed?
    end

    def subreddit
      @subreddit ||= client.subreddit_from_name(@name)
    end

    def settings
      @settings ||= subreddit.to_h
    end

    def update(new_settings = {})
      response = subreddit.admin_edit(new_settings)

      log_errors response.body[:json][:errors], new_settings
    rescue Faraday::TimeoutError
      log 'Timeout error while updating settings.'
    end

    def log_errors(errors, new_settings)
      return unless errors && errors.count.positive?

      errors.each do |error|
        log "#{error[0]}: #{error[1]} (#{error[2]})"

        next unless error[0] == 'TOO_LONG' && error[1] =~ /max: \d+/

        # TODO: Message the moderators of the subreddit to tell them their
        # sidebar is X characters too long.
        puts "New length is #{new_settings[error[2].to_sym].length}"
      end
    end

    # TODO: Make this an actual logger, so we can log to something different
    def log(message)
      puts Time.now.strftime "[%Y-%m-%d %H:%M:%S] #{@name}: #{message}"
    end

    # Returns the post ID
    def submit(title, text:, sticky: false, sort: '', flair: nil)
      begin
        thing = subreddit.submit(title, text: text, sendreplies: false)
      rescue Redd::Error::InvalidCaptcha => captcha
        raise captcha unless ENV['CAPTCHA']

        captcha_id = captcha.body[:json][:captcha]

        puts "http://www.reddit.com/captcha/#{captcha_id}.png"

        response = gets.chomp
        puts "Got #{captcha}"

        thing = subreddit.submit(title, response, captcha_id,
                                 text: text,
                                 sendreplies: false)
      end

      # Why doesn't the redd gem just return a Redd::Objects::Submission?
      submission(id: thing[:id]).tap do |post|
        begin
          post.set_sticky if sticky && !post[:stickied]
        rescue Redd::Error::Conflict
          # It was already stickied
        end

        post.suggested_sort = sort unless sort == ''
        post.flair_template_id = flair if flair
      end
    end

    def edit(id:, body: nil, sticky: nil)
      return unless body || !sticky.nil?

      post = submission id: id

      post.edit(body) if body

      begin
        post.set_sticky if sticky && !post[:stickied]
        post.unset_sticky if sticky == false && post[:stickied]
      rescue Redd::Error::Conflict
        # It was already stickied
      end
    end

    def submission(id:)
      return @submissions[id] if @submissions[id]

      submissions = client.from_fullname "t3_#{id}"

      raise "Unable to load post #{id}." unless submissions

      @submissions[id] = submissions.first
    end

    protected

    def sidebar_template
      body = template_for('sidebar')[0]

      Template::Sidebar.new body: body, bot: @bot, subreddit: self
    end

    def gamechat_template(gid:, title:)
      body, default_title = template_for('gamechat')

      title = title && !title.empty? ? title : default_title

      Template::Gamechat.new body: body,
                             bot: @bot,
                             subreddit: self,
                             gid: gid,
                             title: title
    end

    def gamechat_update_template(gid:, post_id:)
      body = template_for('gamechat_update')[0]

      Template::Gamechat.new body: body,
                             bot: @bot,
                             subreddit: self,
                             gid: gid,
                             post_id: post_id
    end

    def pregame_template(gid:)
      body, title = template_for('pregame')

      Template::Gamechat.new body: body,
                             bot: @bot,
                             subreddit: self,
                             gid: gid,
                             title: title
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

      raise "#{@name} does not have a #{type} template." if result.count < 1

      [result[0]['body'], result[0]['title']]
    end
  end
end
