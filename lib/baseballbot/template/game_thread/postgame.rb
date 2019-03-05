# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module Postgame
        def winner_flag
          home_rhe['runs'] > away_rhe['runs'] ? 'home' : 'away'
        end

        def loser_flag
          home_rhe['runs'] > away_rhe['runs'] ? 'away' : 'home'
        end

        def winning_pitcher
          return unless final?

          pitcher_id = feed.dig('liveData', 'decisions', 'winner', 'id')

          return unless pitcher_id

          data = boxscore.dig 'teams', winner_flag, 'players', "ID#{pitcher_id}"
          stats = data['seasonStats']['pitching']

          {
            name: player_name(data),
            record: stats.values_at('wins', 'losses').join('-'),
            era: stats['era']
          }
        end

        def losing_pitcher
          return unless final?

          pitcher_id = feed.dig('liveData', 'decisions', 'loser', 'id')

          return unless pitcher_id

          data = boxscore.dig 'teams', loser_flag, 'players', "ID#{pitcher_id}"
          stats = data['seasonStats']['pitching']

          {
            name: player_name(data),
            record: stats.values_at('wins', 'losses').join('-'),
            era: stats['era']
          }
        end

        def save_pitcher
          return unless final?

          pitcher_id = feed.dig('liveData', 'decisions', 'save', 'id')

          return unless pitcher_id

          data = boxscore.dig 'teams', winner_flag, 'players', "ID#{pitcher_id}"

          {
            name: player_name(data),
            saves: data['seasonStats']['pitching']['saves'],
            era: data['seasonStats']['pitching']['era']
          }
        end

        def decisions_table
          winner = pitcher_decision(winning_pitcher, :record)
          loser = pitcher_decision(losing_pitcher, :record)
          save = pitcher_decision(save_pitcher, :saves)

          "Winning Pitcher|Losing Pitcher|Save\n" \
          ":-:|:-:|:-:\n#{winner}|#{loser}|#{save}"
        end

        def pitcher_decision(pitcher, info_key)
          return '' unless pitcher

          format "%<name>s (%<#{info_key}>s, %<era>s)", pitcher
        end
      end
    end
  end
end
