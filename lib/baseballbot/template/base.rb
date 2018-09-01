# frozen_string_literal: true

class Baseballbot
  module Template
    class Base
      # This is kept here because of inheritance
      Dir.glob(
        File.join(File.dirname(__FILE__), 'shared', '*.rb')
      ).each { |file| require_relative file }

      include MarkdownHelpers
      using TemplateRefinements

      include Template::Shared::Standings

      DELIMITER = '[](/baseballbot)'

      def initialize(body:, subreddit:)
        @subreddit = subreddit

        @template = ERB.new body, nil, '<>'
        @bot = subreddit.bot
      end

      def body
        @template.result binding
      end

      # Get the default subreddit for this team
      def subreddit(code)
        @subreddit.options.dig('subreddits', code.upcase) ||
          Baseballbot::Subreddits::DEFAULT_SUBREDDITS[code.upcase]
      end

      def replace_regexp
        delimiter = Regexp.escape DELIMITER

        Regexp.new "#{delimiter}(.*)#{delimiter}", Regexp::MULTILINE
      end

      # Temporary extra replacement to move to the new delimiter
      def replace_in(text)
        if text.is_a?(Redd::Models::Submission)
          text = CGI.unescapeHTML(text.selftext)
        end

        text
          .gsub('[](/updates)', DELIMITER)
          .sub(replace_regexp, "#{DELIMITER}\n#{body}\n#{DELIMITER}")
      end

      def timestamp(action = nil)
        return @subreddit.now.strftime '%-I:%M %p' unless action

        italic "#{action} at #{@subreddit.now.strftime '%-I:%M %p'}."
      end
    end
  end
end
