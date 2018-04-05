# frozen_string_literal: true

class Baseballbot
  module Template
    class Gamechat
      module Teams
        def away_record
          game_data.dig('teams', 'away', 'record')
            &.values_at('wins', 'losses')
            &.join('-')
        end

        def home_record
          game_data.dig('teams', 'home', 'record')
            &.values_at('wins', 'losses')
            &.join('-')
        end

        def home_team
          @home_team ||= @bot.api.team game_data.dig('teams', 'home', 'id')
        end

        def away_team
          @away_team ||= @bot.api.team game_data.dig('teams', 'away', 'id')
        end

        def opponent
          return home_team if @subreddit.team&.id == away_team.id

          away_team
        end

        def team
          @subreddit.team || home_team
        end
      end
    end
  end
end
