# frozen_string_literal: true

class Baseballbot
  module Template
    class Gamechat
      module Postgame
        def winning_pitcher
          pitcher_id = @feed.linescore.dig('pitchers', 'win')

          team_id = @feed.dig(
            'liveData', 'players', 'allPlayers', "ID#{pitcher_id}", 'uniformID'
          )

          team = team_id == home_id ? 'home' : 'away'

          data = @feed.boxscore.dig('teams', team, 'players', "ID#{pitcher_id}")
          stats = data['seasonStats']['pitching']

          {
            name: data['name']['boxname'],
            record: stats.values_at('wins', 'losses').join('-'),
            era: stats['era']
          }
        end

        def losing_pitcher
          pitcher_id = @feed.linescore.dig('pitchers', 'loss')

          team_id = @feed.dig(
            'liveData', 'players', 'allPlayers', "ID#{pitcher_id}", 'uniformID'
          )

          team = team_id == home_id ? 'home' : 'away'

          data = @feed.boxscore.dig('teams', team, 'players', "ID#{pitcher_id}")
          stats = data['seasonStats']['pitching']

          {
            name: data['name']['boxname'],
            record: stats.values_at('wins', 'losses').join('-'),
            era: stats['era']
          }
        end

        def save_pitcher
          pitcher_id = @feed.linescore.dig('pitchers', 'save')

          team_id = @feed.dig(
            'liveData', 'players', 'allPlayers', "ID#{pitcher_id}", 'uniformID'
          )

          team = team_id == home_id ? 'home' : 'away'

          data = @feed.boxscore.dig('teams', team, 'players', "ID#{pitcher_id}")

          {
            name: data['name']['boxname'],
            saves: data['seasonStats']['pitching']['saves'],
            era: data['seasonStats']['pitching']['era']
          }
        end

        def decisions_table
          winner = '%<name>s (%<record>s, %<era>s)'.format(winning_pitcher)
          loser = '%<name>s (%<record>s, %<era>s)'.format(losing_pitcher)
          save = '%<name>s (%<saves>s, %<era>s)'.format(losing_pitcher)

          "Winning Pitcher|Losing Pitcher|Save\n" \
          ":-:|:-:|:-:\n#{winner}|#{loser}|#{save}"
        end
      end
    end
  end
end
