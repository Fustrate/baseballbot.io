module TemplateRefinements
  refine String do
    def bold
      "**#{self}**"
    end

    def italic
      "*#{self}*"
    end
  end

  refine Numeric do
    def ordinalize
      "#{self}#{ordinal}"
    end

    def ordinal
      abs_number = to_i.abs

      if (11..13).include?(abs_number % 100)
        'th'
      else
        case abs_number % 10
        when 1 then 'st'
        when 2 then 'nd'
        when 3 then 'rd'
        else        'th'
        end
      end
    end
  end
end

class Baseballbot
  module Template
    class Base
      using TemplateRefinements

      def initialize(body:, bot:)
        @body = body
        @template = ERB.new body, nil, '<>'
        @bot = bot
        @subreddits = {}
      end

      def result
        @template.result binding
      end

      def bold(text)
        text.to_s.bold
      end

      def italic(text)
        text.to_s.italic
      end

      def sup(text)
        "^(#{text})"
      end

      def pct(percent)
        format('%0.3f', percent).sub(/\A0+/, '')
      end

      def gb(games_back)
        return '-' if games_back == 0

        games_back % 1.0 == 0 ? games_back.to_i : games_back
      end

      # Change the subreddit to use for a team, only in this template
      #   <% subreddits LAD: 'Dodgers', SF: 'WTF %>'
      def subreddits(mapping = {})
        normalized = mapping.map { |code, name| [code.to_s.upcase, name.to_s] }

        @subreddits.merge! Hash[normalized]
      end

      # Get the default subreddit for this team
      def subreddit(code)
        @subreddits[code.upcase] || Baseballbot.subreddits[code.upcase]
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
        text.sub replace_regexp,
                 "#{delimiter}\n#{result}\n#{delimiter close: true}"
      end

      def timestamp(action = nil)
        return time.strftime '%-I:%M %p %Z' unless action

        italic "#{action} at #{time.strftime '%-I:%M %p %Z'}."
      end
    end
  end
end
