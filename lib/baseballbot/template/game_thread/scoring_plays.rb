# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module ScoringPlays
        def scoring_plays
          return [] unless started? && feed.plays

          feed.plays['allPlays']
            .values_at(*feed.plays['scoringPlays'])
            .map { |play| format_play(play) }
        end

        def scoring_plays_table
          rows = scoring_plays.map do |play|
            [
              "#{play[:side]}#{play[:inning]}",
              play[:event],
              event_score(play)
            ].join('|')
          end

          "Inning|Event|Score\n:-:|-|:-:\n#{rows.join("\n")}"
        end

        protected

        def format_play(play)
          {
            side: play['about']['halfInning'] == 'top' ? 'T' : 'B',
            team: play['about']['halfInning'] == 'top' ? opponent : team,
            inning: play['about']['inning'],
            event: play['result']['description'],
            score: [play['result']['homeScore'], play['result']['awayScore']]
          }
        end

        def event_score(play)
          if play[:side] == 'T'
            "#{play[:score][0]}-#{bold play[:score][1]}"
          else
            "#{bold play[:score][0]}-#{play[:score][1]}"
          end
        end
      end
    end
  end
end
