class Baseballbot
  module Template
    class Base
      def initialize(body:, bot:)
        @template = ERB.new body, nil, '<>'
        @bot = bot
      end

      def result
        @template.result binding
      end

      def bold(text)
        "**#{text}**"
      end

      def italic(text)
        "*#{text}*"
      end

      def pct(percent)
        format('%0.3f', percent).sub(/\A0+/, '')
      end

      def gb(games_back)
        return '-' if games_back == 0

        games_back % 1.0 == 0 ? games_back.to_i : games_back
      end

      # Get the default subreddit for this team
      def subreddit(code)
        Baseballbot.subreddits[code.upcase]
      end

      def link_to(text = '', options = {})
        title = %( "#{options[:title]}") if options[:title]

        return "[#{text}](/r/#{options[:sub]}#{title})" if options[:sub]
        return "[#{text}](#{options[:url]}#{title})" if options[:url]
        return "[#{text}](/u/#{options[:user]}#{title})" if options[:user]

        "[#{text}](/##{title})"
      end

      def delimiter(escape: false, close: false)
        if escape
          Regexp.escape delimiter(close: close)
        else
          '[](/updates)'
        end
      end

      def replace_regexp
        delim_start = delimiter(escape: true)
        delim_end   = delimiter(escape: true, close: true)

        Regexp.new "#{delim_start}(.*)#{delim_end}", Regexp::MULTILINE
      end

      def replace_in(text)
        text.sub replace_regexp, "#{delimiter}\n#{result}\n#{delimiter}"
      end
    end
  end
end
