class Baseballbot
  module Template
    class Gamechat
      module LineScore
        def home
          unless @game.started? && @game.boxscore
            return {
              runs: 0,
              hits: 0,
              errors: 0
            }
          end

          rhe = @game.boxscore.at_xpath '//boxscore/linescore'

          {
            runs: rhe['home_team_runs'].to_i,
            hits: rhe['home_team_hits'].to_i,
            errors: rhe['home_team_errors'].to_i
          }
        end

        def away
          unless @game.started? && @game.boxscore
            return {
              runs: 0,
              hits: 0,
              errors: 0
            }
          end

          rhe = @game.boxscore.at_xpath '//boxscore/linescore'

          {
            runs: rhe['away_team_runs'].to_i,
            hits: rhe['away_team_hits'].to_i,
            errors: rhe['away_team_errors'].to_i
          }
        end

        def lines
          lines = [[nil] * 9, [nil] * 9]

          return lines unless @game.started? && @game.boxscore

          bs = @game.boxscore

          bs.xpath('//boxscore/linescore/inning_line_score').each do |inning|
            if inning['away'] && !inning['away'].empty?
              lines[0][inning['inning'].to_i - 1] = inning['away']

              # In case of extra innings
              lines[1][inning['inning'].to_i - 1] = nil
            end

            if inning['home'] && !inning['home'].empty?
              lines[1][inning['inning'].to_i - 1] = inning['home']
            end
          end

          lines
        end

        def line_score
          [
            " |#{ (1..(lines[0].count)).to_a.join('|') }|R|H|E",
            ":-:|#{ (':-:|' * lines[0].count) }:-:|:-:|:-:",
            "[#{ game.away_team.code }](/#{ game.away_team.code })|" \
              "#{ lines[0].join('|') }|#{ bold away[:runs] }|" \
              "#{ bold away[:hits] }|#{ bold away[:errors] }",
            "[#{ game.home_team.code }](/#{ game.home_team.code })|" \
              "#{ lines[1].join('|') }|#{ bold home[:runs] }|" \
              "#{ bold home[:hits] }|#{ bold home[:errors] }"
          ].join "\n"
        end

        def line_score_status
          if game.over?
            'Final'
          elsif runners.empty?
            "#{outs} #{outs == 1 ? 'Out' : 'Outs'}, #{inning}"
          else
            "#{runners}, #{outs} #{outs == 1 ? 'Out' : 'Outs'}, #{inning}"
          end
        end
      end
    end
  end
end
