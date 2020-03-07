# frozen_string_literal: true

class Baseballbot
  module Posts
    class Postgame < GameThread
      def create!
        post_thread!

        info "[PST] #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"

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
          type: 'postgame'
        )

        # The title uses the template to see who won
        @template.title = postgame_title
      end

      def post_process
        update_sticky @subreddit.sticky_game_threads?
        update_flair postgame_flair

        @bot.db.exec_params(
          'UPDATE game_threads SET post_game_post_id = $1 WHERE id = $2',
          [@submission.id, @id]
        )
      end

      def postgame_flair
        flairs = @subreddit.options.dig('postgame', 'flair')

        return unless flairs

        return flairs['won'] if @template.won? && flairs['won']
        return flairs['lost'] if @template.lost? && flairs['lost']

        flairs
      end

      def postgame_title
        titles = @subreddit.options.dig('postgame', 'title')

        return titles if titles.is_a?(String)

        titles[title_key] || titles['default'] || titles.values.first

        # # Spring training games can end in a tie.
        # titles['tie'] || titles
      end

      def playoffs?
        %w[F D L W].include? @template.game_data.dig('game', 'type')
      end

      def title_key
        return 'won' if @template.won?

        return 'lost' if @template.lost?

        return 'playoffs' if playoffs?

        'default'
      end
    end
  end
end
