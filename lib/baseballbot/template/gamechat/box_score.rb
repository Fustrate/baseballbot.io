# frozen_string_literal: true

class Baseballbot
  module Template
    class Gamechat
      module BoxScore
        BASE_XPATH = '//boxscore/team[@team_flag="%<flag>s"]'
        BATTER_XPATH = "#{BASE_XPATH}/batting/batter[@bat_order]"
        PITCHER_XPATH = "#{BASE_XPATH}/pitching/pitcher"

        def home_batters
          return [] unless @game.started? && @game.files[:rawboxscore]

          @game.files[:rawboxscore]
            .xpath(format(BATTER_XPATH, flag: 'home'))
            .to_a
            .reject { |batter| batter['bat_order'].to_i > 1099 }
            .sort_by { |batter| batter['bat_order'] }
        end

        def away_batters
          return [] unless @game.started? && @game.files[:rawboxscore]

          @game.files[:rawboxscore]
            .xpath(format(BATTER_XPATH, flag: 'away'))
            .to_a
            .reject { |batter| batter['bat_order'].to_i > 1099 }
            .sort_by { |batter| batter['bat_order'] }
        end

        def batters
          home_batters.zip away_batters
        end

        def home_pitchers
          return [] unless @game.started? && @game.files[:rawboxscore]

          @game.files[:rawboxscore]
            .xpath(format(PITCHER_XPATH, flag: 'home'))
            .to_a
            .sort_by { |pitcher| pitcher['pitch_order'] }
        end

        def away_pitchers
          return [] unless @game.started? && @game.files[:rawboxscore]

          @game.files[:rawboxscore]
            .xpath(format(PITCHER_XPATH, flag: 'away'))
            .to_a
            .sort_by { |batter| batter['pitch_order'] }
        end

        def pitchers
          home_pitchers.zip away_pitchers
        end

        def batter_row(batter)
          return ' ||||||||' unless batter

          is_replacement = (batter['bat_order'].to_i % 100).positive?
          spacer = '[](/spacer)' if is_replacement
          url = link_to batter['name'], url: player_url(batter['id'])

          [
            "#{spacer}#{is_replacement ? batter['pos'] : (bold batter['pos'])}",
            "#{spacer}#{url}",
            batter['ab'],
            batter['r'],
            batter['h'],
            batter['rbi'],
            batter['bb'],
            batter['so'],
            batter['bis_avg']
          ].join '|'
        end

        def pitcher_row(pitcher)
          return ' ||||||||' unless pitcher

          [
            link_to(pitcher['name'],
                    url: player_url(pitcher['id']),
                    title: "Game Score: #{pitcher['game_score']}"),
            "#{pitcher['out'].to_i / 3}.#{pitcher['out'].to_i % 3}",
            pitcher['h'],
            pitcher['r'],
            pitcher['er'],
            pitcher['bb'],
            pitcher['so'],
            "#{pitcher['np']}-#{pitcher['s']}",
            pitcher['bis_era']
          ].join '|'
        end
      end
    end
  end
end
