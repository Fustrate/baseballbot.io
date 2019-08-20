# frozen_string_literal: true

class Baseballbot
  module Posts
    class Postgame < GameThread
      def create!
        @template = postgame_template

        # The title uses the template to see who won
        @template.title = postgame_title

        @submission = @subreddit.submit(
          title: @template.title,
          text: @template.body
        )

        update_sticky @subreddit.sticky_game_threads?
        update_flair postgame_flair

        info "[PST] #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"

        @submission
      end

      protected

      def postgame_template
        Template::GameThread.new(
          subreddit: @subreddit,
          game_pk: @game_pk,
          type: 'postgame'
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

        return titles['won'] if @template.won? && titles['won']
        return titles['lost'] if @template.lost? && titles['lost']

        playoffs = %w[F D L W].include? @template.game_data.dig('game', 'type')

        titles[playoffs ? 'postseason' : 'default'] || titles.values.first

        # # Spring training games can end in a tie.
        # titles['tie'] || titles
      end
    end
  end
end
