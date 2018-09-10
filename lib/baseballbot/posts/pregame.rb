# frozen_string_literal: true

class Baseballbot
  module Posts
    class Pregame < GameThread
      def create!
        post_pregame_thread!

        info "[PRE] #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"

        @submission
      end

      protected

      def post_pregame_thread!
        @bot.use_account(@subreddit.account.name)

        @template = pregame_template

        @submission = @subreddit.submit(
          title: @template.title,
          text: @template.body
        )

        change_status 'Pregame'

        update_sticky @subreddit.sticky_game_threads?
        update_flair @subreddit.options.dig('pregame', 'flair')
      end

      def pregame_template
        Template::GameThread.new(
          body: @subreddit.template_for('pregame'),
          subreddit: @subreddit,
          game_pk: @game_pk,
          title: @subreddit.options.dig('pregame', 'title')
        )
      end
    end
  end
end
