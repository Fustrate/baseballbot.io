# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module Game
        UMPIRE_POSITIONS = {
          'Home Plate' => 'HP',
          'First Base' => '1B',
          'Second Base' => '2B',
          'Third Base' => '3B',
          'Left Field' => 'LF',
          'Right Field' => 'RF'
        }.freeze

        BASERUNNERS = [
          'Bases empty',
          'Runner on first',
          'Runner on second',
          'First and second',
          'Runner on third',
          'First and third',
          'Second and third',
          'Bases loaded'
        ].freeze

        def start_time_utc
          @start_time_utc ||= Time.parse game_data.dig('datetime', 'dateTime')
        end

        def start_time_et
          Baseballbot::Utility.parse_time(
            start_time_utc,
            in_time_zone: TZInfo::Timezone.get('America/New_York')
          )
        end

        def start_time_local
          Baseballbot::Utility
            .parse_time(start_time_utc, in_time_zone: @subreddit.timezone)
        end

        def gid
          @gid ||= game_data.dig('game', 'id').gsub(/[^a-z0-9]/, '_')
        end

        def date
          @date ||= Date.parse game_data.dig('datetime', 'dateTime')
        end

        def umpires
          feed
            .dig('liveData', 'boxscore', 'officials')
            .map do |umpire|
              [
                UMPIRE_POSITIONS[umpire['officialType']],
                umpire['official']['fullName']
              ]
            end
            .to_h
        end

        def venue_name
          game_data.dig('venue', 'name')
        end

        def weather
          data = game_data.dig('weather') || {}

          "#{data['temp']}°F, #{data['condition']}" if data['condition']
        end

        def wind
          game_data.dig('weather', 'wind')
        end

        def attendance
          nil
        end

        def preview?
          game_data.dig('status', 'abstractGameState') == 'Preview'
        end

        def final?
          game_data.dig('status', 'abstractGameState') == 'Final'
        end
        alias over? final?

        def postponed?
          game_data.dig('status', 'detailedState') == 'Postponed'
        end

        def live?
          !(preview? || final?)
        end

        def started?
          !preview?
        end

        def inning
          return game_data.dig('status', 'detailedState') unless live?

          "#{linescore['inningState']} of the " \
          "#{linescore['currentInningOrdinal']}"
        end

        def outs
          linescore['outs'] if live? && linescore
        end

        def runners
          return '' unless live? && linescore&.dig('offense')

          bitmap = 0b000
          bitmap |= 0b001 if linescore.dig('offense', 'first')
          bitmap |= 0b010 if linescore.dig('offense', 'second')
          bitmap |= 0b100 if linescore.dig('offense', 'third')

          BASERUNNERS[bitmap]
        end

        def game_stats(player)
          player['gameStats'] || player['stats'] || {}
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
