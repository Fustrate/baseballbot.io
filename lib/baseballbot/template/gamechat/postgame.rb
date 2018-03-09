# frozen_string_literal: true

class Baseballbot
  module Template
    class Gamechat
      module Postgame
        def winning_team
          home_rhe['runs'] > away_rhe['runs'] ? 'home' : 'away'
        end

        def losing_team
          home_rhe['runs'] > away_rhe['runs'] ? 'away' : 'home'
        end

        def winning_pitcher
          return unless final?

          pitcher_id = @feed.dig('liveData', 'decisions', 'winner', 'id')

          return unless pitcher_id

          data = @feed.boxscore
            .dig('teams', winning_team, 'players', "ID#{pitcher_id}")
          stats = data['seasonStats']['pitching']

          {
            name: player_name(data),
            record: stats.values_at('wins', 'losses').join('-'),
            era: stats['era']
          }
        end

        def losing_pitcher
          return unless final?

          pitcher_id = @feed.dig('liveData', 'decisions', 'loser', 'id')

          return unless pitcher_id

          data = @feed.boxscore
            .dig('teams', losing_team, 'players', "ID#{pitcher_id}")
          stats = data['seasonStats']['pitching']

          {
            name: player_name(data),
            record: stats.values_at('wins', 'losses').join('-'),
            era: stats['era']
          }
        end

        def save_pitcher
          return unless final?

          pitcher_id = @feed.dig('liveData', 'decisions', 'save', 'id')

          return unless pitcher_id

          data = @feed.boxscore
            .dig('teams', winning_team, 'players', "ID#{pitcher_id}")

          {
            name: player_name(data),
            saves: data['seasonStats']['pitching']['saves'],
            era: data['seasonStats']['pitching']['era']
          }
        end

        def decisions_table
          winner = format '%<name>s (%<record>s, %<era>s)', winning_pitcher
          loser = format '%<name>s (%<record>s, %<era>s)', losing_pitcher
          save = if save_pitcher
                   format '%<name>s (%<saves>s, %<era>s)', save_pitcher
                 else
                   ''
                 end

          "Winning Pitcher|Losing Pitcher|Save\n" \
          ":-:|:-:|:-:\n#{winner}|#{loser}|#{save}"
        end
      end
    end
  end
end
