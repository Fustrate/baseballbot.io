class Baseballbot
  module Template
    class Gamechat
      module LineScore
        BLANK_RHE = { runs: 0, hits: 0, errors: 0 }

        def home
          return BLANK_RHE unless @game.started? && @game.boxscore

          rhe_for_side 'home'
        end

        def away
          return BLANK_RHE unless @game.started? && @game.boxscore

          rhe_for_side 'away'
        end

        def lines
          lines = [[nil] * 9, [nil] * 9]

          return lines unless @game.started? && @game.boxscore

          @game.boxscore
            .xpath('//boxscore/linescore/inning_line_score')
            .each { |inning| add_inning_to_line_score(inning, lines: lines) }

          lines
        end

        def line_score
          [
            " |#{(1..(lines[0].count)).to_a.join('|')}|R|H|E",
            ":-:|#{(':-:|' * lines[0].count)}:-:|:-:|:-:",
            "[#{game.away_team.code}](/#{game.away_team.code})|" \
              "#{lines[0].join('|')}|#{bold away[:runs]}|" \
              "#{bold away[:hits]}|#{bold away[:errors]}",
            "[#{game.home_team.code}](/#{game.home_team.code})|" \
              "#{lines[1].join('|')}|#{bold home[:runs]}|" \
              "#{bold home[:hits]}|#{bold home[:errors]}"
          ].join "\n"
        end

        def line_score_status
          return 'Final' if game.over?

          if runners.empty?
            return "#{outs} #{outs == 1 ? 'Out' : 'Outs'}, #{inning}"
          end

          "#{runners}, #{outs} #{outs == 1 ? 'Out' : 'Outs'}, #{inning}"
        end

        protected

        def rhe_for_side(side)
          @rhe ||= @game.boxscore.at_xpath '//boxscore/linescore'

          {
            runs: @rhe["#{side}_team_runs"].to_i,
            hits: @rhe["#{side}_team_hits"].to_i,
            errors: @rhe["#{side}_team_errors"].to_i
          }
        end

        def add_inning_to_line_score(inning, lines:)
          if inning['away'] && !inning['away'].empty?
            lines[0][inning['inning'].to_i - 1] = inning['away']

            # In case of extra innings
            lines[1][inning['inning'].to_i - 1] = nil
          end

          return unless inning['home'] && !inning['home'].empty?

          lines[1][inning['inning'].to_i - 1] = inning['home']
        end
      end
    end
  end
end
