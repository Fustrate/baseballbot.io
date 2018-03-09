# frozen_string_literal: true

class Baseballbot
  module Template
    class Gamechat
      module BoxScore
        def probable_away_starter
          pitcher_id = @feed['gameData']['probablePitchers']['away']['id']
          @feed['gameData']['players']["ID#{pitcher_id}"]
        end

        def probable_home_starter
          pitcher_id = @feed['gameData']['probablePitchers']['home']['id']
          @feed['gameData']['players']["ID#{pitcher_id}"]
        end

        def home_batters
          return [] unless started? && @feed.boxscore

          @feed.boxscore['teams']['home']['players']
            .values
            .select { |batter| batter['battingOrder'] }
            .sort_by { |batter| batter['battingOrder'] }
        end

        def away_batters
          return [] unless started? && @feed.boxscore

          @feed.boxscore['teams']['away']['players']
            .values
            .select { |batter| batter['battingOrder'] }
            .sort_by { |batter| batter['battingOrder'] }
        end

        def batters
          home_batters.zip away_batters
        end

        def home_pitchers
          return [] unless started? && @feed

          @feed.boxscore.dig('teams', 'home', 'pitchers').each do |id|
            @feed.boxscore('teams', 'home', 'players', "ID#{id}")
          end
        end

        def away_pitchers
          return [] unless started? && @feed

          @feed.boxscore.dig('teams', 'away', 'pitchers').each do |id|
            @feed.boxscore('teams', 'away', 'players', "ID#{id}")
          end
        end

        def pitchers
          home_pitchers.zip away_pitchers
        end

        def batter_row(batter)
          return ' ||||||||' unless batter

          replacement = (batter['battingOrder'].to_i % 100).positive?
          spacer = '[](/spacer)' if replacement

          pos = replacement ? batter['position'] : (bold batter['position'])

          batting = batter['gameStats']['batting']

          [
            "#{spacer}#{pos}",
            "#{spacer}#{player_link(batter)}",
            batting['atBats'],
            batting['runs'],
            batting['hits'],
            batting['rbi'],
            batting['baseOnBalls'],
            batting['strikeOuts'],
            batter['seasonStats']['batting']['avg']
          ].join '|'
        end

        def pitcher_row(pitcher)
          return ' ||||||||' unless pitcher

          pitching = pitcher['gameStats']['pitching']

          [
            player_link(pitcher, title: 'Game Score: ???'),
            pitching['inningsPitched'],
            pitching['hits'],
            pitching['runs'],
            pitching['earnedRuns'],
            pitching['baseOnBalls'],
            pitching['strikeOuts'],
            "#{pitching['pitchesThrown']}-#{pitching['strikes']}",
            pitcher['seasonStats']['pitching']['era']
          ].join '|'
        end
      end
    end
  end
end
