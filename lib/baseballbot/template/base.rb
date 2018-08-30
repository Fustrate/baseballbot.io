# frozen_string_literal: true

require_relative 'markdown_helpers'
require_relative 'template_refinements'

class Baseballbot
  module Template
    class Base
      include MarkdownHelpers
      using TemplateRefinements

      DELIMITER = '[](/baseballbot)'

      def initialize(body:, bot:)
        @body = body
        @template = ERB.new body, nil, '<>'
        @bot = bot
        @subreddits = {}
      end

      def body
        @template.result binding
      end

      # Change the subreddit to use for a team, only in this template
      #   <% subreddits LAD: 'Dodgers', SF: 'WTF' %>
      def subreddits(mapping = {})
        normalized = mapping.map { |code, name| [code.to_s.upcase, name.to_s] }

        @subreddits.merge! Hash[normalized]
      end

      # Get the default subreddit for this team
      def subreddit(code)
        @subreddits[code.upcase] ||
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
        return @subreddit.now.strftime '%-I:%M %p %Z' unless action

        italic "#{action} at #{@subreddit.now.strftime '%-I:%M %p %Z'}."
      end
    end
  end
end
