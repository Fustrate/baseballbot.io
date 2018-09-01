# frozen_string_literal: true

class Baseballbot
  module Posts
    class Postgame < GameThread
      DEFAULT_TITLE = 'Postgame Thread: ' \
                      '%{away_name} %{away_runs} @ %{home_name} %{home_runs}'

      def create!
        @template = postgame_template

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
          body: @subreddit.template_for('postgame'),
          subreddit: @subreddit,
          game_pk: @game_pk,
          title: postgame_title
        )
      end

      def postgame_flair
        flairs = @subreddit.options.dig('postgame', 'flair')

        return flairs['won'] if @template.won? && flairs['won']
        return flairs['lost'] if @template.lost? && flairs['lost']

        flairs
      end

      def postgame_title
        titles = @subreddit.options.dig('postgame', 'title') || DEFAULT_TITLE

        return titles['won'] if @template.won? && titles['won']
        return titles['lost'] if @template.lost? && titles['lost']

        # Spring training games can end in a tie.
        titles['tie'] || titles
      end
    end
  end
end
