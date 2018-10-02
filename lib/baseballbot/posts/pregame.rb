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

        # The title uses @template
        @template.title = pregame_title

        @submission = @subreddit.submit(
          title: @template.title,
          text: @template.body
        )

        change_status 'Pregame'

        update_sticky @subreddit.sticky_game_threads?
        update_flair @subreddit.options.dig('pregame', 'flair')
      end

      def pregame_title
        titles = @subreddit.options.dig('pregame', 'title')

        return titles if titles.is_a?(String)

        playoffs = %w[F D L W].include? @template.game_data.dig('game', 'type')

        titles[playoffs ? 'postseason' : 'default'] || titles.values.first
      end

      def pregame_template
        Template::GameThread.new(
          subreddit: @subreddit,
          game_pk: @game_pk,
          type: 'pregame'
        )
      end
    end
  end
end
