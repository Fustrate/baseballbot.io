class Baseballbot
  module Template
    class Gamechat
      module ScoringPlays
        def scoring_plays
          plays = []

          return plays unless @game.started?

          data = Nokogiri::XML open_file('inning/inning_Scores.xml')

          data.xpath('//scores/score').each do |play|
            plays << {
              side:   play['top_inning'] == 'Y' ? 'T' : 'B',
              team:   play['top_inning'] == 'Y' ? opponent : team,
              inning: play['inn'],
              event:  play.at_xpath('*[@des and @score="T"]')['des'],
              score:  [play['home'].to_i, play['away'].to_i]
            }
          end

          plays
        rescue OpenURI::HTTPError
          # There's no inning_Scores.xml file right now
          []
        end

        def scoring_plays_table
          table = [
            'Inning|Event|Score',
            ':-:|-|:-:'
          ]

          scoring_plays.each do |event|
            score = if event[:side] == 'T'
                      "#{ event[:score][0] }-#{ bold event[:score][1] }"
                    else
                      "#{ bold event[:score][0] }-#{ event[:score][1] }"
                    end

            table << [
              "#{ event[:inning_side] }#{ event[:inning] }",
              event[:event],
              score
            ].join('|')
          end

          table.join "\n"
        end
      end
    end
  end
end
