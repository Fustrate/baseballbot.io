# frozen_string_literal: true

class Baseballbot
  module Template
    class NoHitter < GameThread
      def initialize(body:, title:, subreddit:, game_pk:, flag:, post_id: nil)
        super(
          body: body,
          subreddit: subreddit,
          game_pk: game_pk,
          title: title,
          post_id: post_id
        )

        @flag = flag
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
