# frozen_string_literal: true

class Baseballbot
  module Template
    class Gamechat
      module Teams
        def away_name
          game_data.dig('teams', 'away', 'teamName')
        end

        def away_code
          game_data.dig('teams', 'away', 'abbreviation')
        end

        def home_name
          game_data.dig('teams', 'home', 'teamName')
        end

        def home_code
          game_data.dig('teams', 'home', 'abbreviation')
        end

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

        def away_id
          game_data.dig('teams', 'away', 'teamID')
        end

        def home_id
          game_data.dig('teams', 'home', 'teamID')
        end

        def opponent
          return @bot.gameday.team(home_code) if @subreddit.team&.id == away_id

          @bot.gameday.team(away_code)
        end

        def team
          @subreddit.team || @bot.gameday.team(home_code)
        end
      end
    end
  end
end
