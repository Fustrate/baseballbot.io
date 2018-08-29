# frozen_string_literal: true

module Baseballbot
  module Posts
    class Base
      attr_reader :submission, :template

      def initialize(subreddit:, title: nil)
        @subreddit = subreddit
        @bot = subreddit.bot
        @title = title
      end

      def update_flair(flair)
        return unless flair

        @bot.use_account @subreddit.account.name

        @subreddit.set_flair @submission, flair['text'], css_class: flair['class']
      end

      def update_sticky(sticky = false)
        @bot.use_account @subreddit.account.name

        if @submission.stickied
          @submission.remove_sticky if sticky == false
        elsif sticky
          @submission.make_sticky
        end
      end

      def update_suggested_sort(sort = '')
        @bot.use_account @subreddit.account.name

        return if sort == ''

        @submission.set_suggested_sort sort
      end

      protected

      def info(message)
        @bot.logger.info(message)
      end
    end
  end
end
