# frozen_string_literal: true

class Baseballbot
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

        return update_flair_template(flair) if flair['flair_template_id']

        @subreddit.set_flair(
          @submission,
          flair['text'],
          css_class: flair['class']
        )
      end

      def update_flair_template(flair)
        @subreddit.set_flair_template(
          @submission,
          flair['flair_template_id'],
          text: flair['text']
        )
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
