# frozen_string_literal: true

class Baseballbot
  module Template
    class Gamechat
      module BoxScore
        def probable_away_starter
          pitcher_id = game_data.dig('probablePitchers', 'away', 'id')

          return unless pitcher_id

          boxscore.dig('teams', 'away', 'players', "ID#{pitcher_id}")
        end

        def probable_home_starter
          pitcher_id = game_data.dig('probablePitchers', 'home', 'id')

          return unless pitcher_id

          boxscore.dig('teams', 'home', 'players', "ID#{pitcher_id}")
        end

        def game_stats(player)
          player['gameStats'] || player['stats'] || {}
        end

        def batting_order(batter)
          return batter['battingOrder'].to_i if batter['battingOrder']

          game_stats(batter).dig('batting', 'battingOrder').to_i
        end

        def home_batters
          return [] unless started? && boxscore

          boxscore['teams']['home']['players']
            .values
            .select { |batter| batting_order(batter).positive? }
            .sort_by { |batter| batting_order batter }
        end

        def away_batters
          return [] unless started? && boxscore

          boxscore['teams']['away']['players']
            .values
            .select { |batter| batting_order(batter).positive? }
            .sort_by { |batter| batting_order batter }
        end

        def batters
          full_zip home_batters, away_batters
        end

        def home_pitchers
          return [] unless started? && boxscore

          boxscore.dig('teams', 'home', 'pitchers').map do |id|
            boxscore.dig('teams', 'home', 'players', "ID#{id}")
          end
        end

        def away_pitchers
          return [] unless started? && boxscore

          boxscore.dig('teams', 'away', 'pitchers').map do |id|
            boxscore.dig('teams', 'away', 'players', "ID#{id}")
          end
        end

        def pitchers
          full_zip home_pitchers, away_pitchers
        end

        def batter_row(batter)
          return ' ||||||||' unless batter

          replacement = (batting_order(batter) % 100).positive?
          spacer = '[](/spacer)' if replacement
          position = batter['position']['abbreviation']

          position = bold(position) unless replacement

          batting = game_stats(batter)['batting']

          [
            "#{spacer}#{position}",
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

          pitching = game_stats(pitcher)['pitching']

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

        def pitcher_line(pitcher)
          return 'TBA' unless pitcher

          format '[%<name>s](%<url>s) (%<wins>d-%<losses>d, %<era>s ERA)',
                 name: pitcher.dig('person', 'fullName'),
                 url: player_url(pitcher.dig('person', 'id')),
                 wins: pitcher.dig('seasonStats', 'pitching', 'wins').to_i,
                 losses: pitcher.dig('seasonStats', 'pitching', 'losses').to_i,
                 era: pitcher.dig('seasonStats', 'pitching', 'era')
        end

        # If the first array isn't at least as big as the second, it gets
        # truncated during a normal zip operation
        def full_zip(one, two)
          return one.zip(two) unless one.length < two.length

          (one + [nil] * (two.length - one.length)).zip(two)
        end
      end
    end
  end
end
