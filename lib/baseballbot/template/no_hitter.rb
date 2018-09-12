# frozen_string_literal: true

# This template is only used when initially posting a no-hitter thread. Updates
# are handled like normal game threads.
class Baseballbot
  module Template
    class NoHitter < GameThread
      def initialize(body:, title:, subreddit:, game_pk:, flag:)
        @flag = flag

        super(
          body: body,
          subreddit: subreddit,
          game_pk: game_pk,
          title: title
        )
      end

      def inspect
        %(#<Baseballbot::Template::NoHitter @game_pk="#{@game_pk}">)
      end

      protected

      def title_interpolations
        pitcher_names = (@flag == 'home' ? home_pitchers : away_pitchers)
          .map { |pitcher| player_name(pitcher) }
          .join(', ')

        super.merge(
          pitcher_names: pitcher_names,
          pitching_team: @flag == 'home' ? home_team.name : away_team.name
        )
      end
    end
  end
end
