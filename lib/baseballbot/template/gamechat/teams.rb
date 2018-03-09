# frozen_string_literal: true

class Baseballbot
  module Template
    class Gamechat
      module Teams
        def away_name
          @feed.dig('gameData', 'teams', 'away', 'teamName')
        end

        def away_code
          @feed.dig('gameData', 'teams', 'away', 'abbreviation')
        end
        alias away_abbrev away_code

        def home_name
          @feed.dig('gameData', 'teams', 'home', 'teamName')
        end

        def home_code
          @feed.dig('gameData', 'teams', 'home', 'abbreviation')
        end
        alias home_abbrev home_code

        def away_record
          @feed.dig('gameData', 'teams', 'away', 'record')
            &.values_at('wins', 'losses')
            &.join('-')
        end

        def home_record
          @feed.dig('gameData', 'teams', 'home', 'record')
            &.values_at('wins', 'losses')
            &.join('-')
        end

        def away_id
          @feed.dig('gameData', 'teams', 'away', 'teamID')
        end

        def home_id
          @feed.dig('gameData', 'teams', 'home', 'teamID')
        end
      end
    end
  end
end
