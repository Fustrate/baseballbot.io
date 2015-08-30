class Baseballbot
  module Template
    class Gamechat
      module ScoringPlays
        def scoring_plays
          return [] unless @game.started?

          Nokogiri::XML(open_file('inning/inning_Scores.xml'))
            .xpath('//scores/score')
            .map { |play| format_play(play) }
        rescue OpenURI::HTTPError
          # There's no inning_Scores.xml file right now
          []
        end

        def scoring_plays_table
          table = [
            'Inning|Event|Score',
            ':-:|-|:-:'
          ]

          scoring_plays.each do |play|
            table << [
              "#{play[:inning_side]}#{play[:inning]}",
              play[:event],
              event_score(play)
            ].join('|')
          end

          table.join "\n"
        end

        protected

        def format_play(play)
          {
            side:   play['top_inning'] == 'Y' ? 'T' : 'B',
            team:   play['top_inning'] == 'Y' ? opponent : team,
            inning: play['inn'],
            event:  play.at_xpath('*[@des and @score="T"]')['des'],
            score:  [play['home'].to_i, play['away'].to_i]
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
