# frozen_string_literal: true

class Baseballbot
  module Template
    class General < Base
      using TemplateRefinements

      attr_reader :title

      def initialize(body:, subreddit:, title: '')
        super(body: body, subreddit: subreddit)

        @title = format_title title
      end

      def inspect
        %(#<Baseballbot::Template::General>)
      end

      protected

      def format_title(title)
        Time.now.strftime title
      end
    end
  end
end
