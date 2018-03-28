# frozen_string_literal: true

class Baseballbot
  module Template
    class Gamechat
      module Game
        UMPIRE_POSITIONS = {
          'Home Plate' => 'HP',
          'First Base' => '1B',
          'Second Base' => '2B',
          'Third Base' => '3B',
          'Left Field' => 'LF',
          'Right Field' => 'RF'
        }.freeze

        def start_time_utc
          @start_time_utc ||= \
            Time.parse feed.dig('gameData', 'datetime', 'dateTime')
        end

        def start_time_et
          TZInfo::Timezone.get('America/New_York').utc_to_local(start_time_utc)
        end

        def start_time_local
          @subreddit.timezone.utc_to_local(start_time_utc)
        end

        def gid
          @gid ||= feed.dig('gameData', 'game', 'id').gsub(/[^a-z0-9]/, '_')
        end

        def date
          @date ||= Date.parse feed.dig('gameData', 'datetime', 'dateTime')
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
          feed.dig('gameData', 'venue', 'name')
        end

        def weather
          data = feed.dig('gameData', 'weather') || {}

          "#{data['temp']}°F, #{data['condition']}" if data['condition']
        end

        def wind
          data = feed.dig('gameData', 'weather') || {}

          data['wind']
        end

        def attendance
          nil
        end

        def home?
          return true unless @subreddit.team

          @home = home_id == @subreddit.team.id
        end

        def won?
          return unless final?

          home? == (home['runs'] > away['runs'])
        end

        def lost?
          return unless final?

          home? == (home['runs'] < away['runs'])
        end

        def preview?
          feed['gameData']['status']['abstractGameState'] == 'Preview'
        end

        def final?
          feed['gameData']['status']['abstractGameState'] == 'Final'
        end
        alias over? final?

        def live?
          !(preview? || final?)
        end

        def started?
          !preview?
        end

        def inning
          return feed['gameData']['status']['detailedState'] unless live?

          "#{linescore['inningState']} of the " \
          "#{linescore['currentInningOrdinal']}"
        end

        def outs
          return unless live? && linescore

          linescore['outs']
        end

        def runners
          return '' unless live? && linescore&.dig('offense')

          bitmap = 0b000
          bitmap |= 0b001 if linescore.dig('offense', 'first')
          bitmap |= 0b010 if linescore.dig('offense', 'second')
          bitmap |= 0b100 if linescore.dig('offense', 'third')

          [
            'Bases empty',
            'Runner on first',
            'Runner on second',
            'First and second',
            'Runner on third',
            'First and third',
            'Second and third',
            'Bases loaded'
          ][bitmap]
        end
      end
    end
  end
end
