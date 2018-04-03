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

      def result
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
        text
          .gsub('[](/updates)', DELIMITER)
          .sub(replace_regexp, "#{DELIMITER}\n#{result}\n#{DELIMITER}")
      end

      def timestamp(action = nil)
        return @subreddit.timezone.strftime '%-I:%M %p' unless action

        italic "#{action} at #{@subreddit.timezone.strftime '%-I:%M %p'}."
      end
    end
  end
end
