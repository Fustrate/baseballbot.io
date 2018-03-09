# frozen_string_literal: true

class Baseballbot
  module Template
    class Gamechat
      module Teams
        def away_name
          @feed.dig('gameData', 'teams', 'away', 'name', 'brief')
        end

        def away_code
          @feed.dig('gameData', 'teams', 'away', 'name', 'abbrev')
        end

        def home_name
          @feed.dig('gameData', 'teams', 'home', 'name', 'brief')
        end

        def home_code
          @feed.dig('gameData', 'teams', 'home', 'name', 'abbrev')
        end

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

        def away_abbrev
          @feed.dig('gameData', 'teams', 'away', 'name', 'abbrev')
        end

        def home_abbrev
          @feed.dig('gameData', 'teams', 'home', 'name', 'abbrev')
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
