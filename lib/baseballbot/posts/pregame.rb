# frozen_string_literal: true

class Baseballbot
  module Posts
    class Pregame < GameThread
      def create!
        post_thread!

        info "[PRE] #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"

        @submission
      end

      protected

      def post_thread!
        @bot.with_reddit_account(@subreddit.account.name) do
          load_template

          @submission = @subreddit.submit(
            title: @template.title,
            text: @template.evaluated_body
          )

          post_process
        end
      end

      def load_template
        @template = Template::GameThread.new(
          subreddit: @subreddit,
          game_pk: @game_pk,
          type: 'pregame'
        )

        # The title uses @template
        @template.title = pregame_title
      end

      def pregame_title
        titles = @subreddit.options.dig('pregame', 'title')

        return titles if titles.is_a?(String)

        playoffs = %w[F D L W].include? @template.game_data.dig('game', 'type')

        titles[playoffs ? 'postseason' : 'default'] || titles.values.first
      end

      def post_process
        change_status 'Pregame'

        update_sticky @subreddit.sticky_game_threads?
        update_flair @subreddit.options.dig('pregame', 'flair')

        @bot.db.exec_params(
          'UPDATE game_threads SET pre_game_post_id = $1 WHERE id = $2',
          [@submission.id, @id]
        )
      end
    end
  end
end
