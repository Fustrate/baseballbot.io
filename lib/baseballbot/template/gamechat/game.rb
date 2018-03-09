# frozen_string_literal: true

class Baseballbot
  module Template
    class Gamechat
      module Game
        UMPIRE_POSITIONS = {
          'home' => 'HP',
          'first' => '1B',
          'second' => '2B',
          'third' => '3B',
          'left' => 'LF',
          'right' => 'RF'
        }.freeze

        def start_time_utc
          @start_time_utc ||= \
            Time.parse @feed['gameData']['datetime']['dateTime']
        end

        def start_time_et
          TZInfo::Timezone.get('America/New_York')
            .utc_to_local(start_time_utc)
            .strftime('%-I:%M %p')
        end

        def start_time_local
          @subreddit.timezone
            .utc_to_local(start_time_utc)
            .strftime('%-I:%M %p')
        end

        def gid
          @feed['gameData']['game']['id'].gsub(/[^a-z0-9]/, '_')
        end

        def date
          @date ||= Date.parse @feed['gameData']['datetime']['dateTime']
        end

        def umpires
          names = @feed.dig('liveData', 'boxscore', 'officials').map do |umpire|
            [UMPIRE_POSITIONS[umpire['position']], umpire['name']]
          end

          Hash[names]
        end

        def venue_name
          @feed.dig('gameData', 'venue', 'name')
        end

        def weather
          data = @feed.dig('gameData', 'weather') || {}

          return unless data['condition']

          "#{data['temp']}°F, #{data['condition']}"
        end

        def wind
          data = @feed.dig('gameData', 'weather') || {}

          return unless data['wind']

          data['wind']
        end

        def attendance
          nil
        end

        def home?
          return true unless @subreddit.team

          @home ||= @game.home_team.code == @subreddit.team.code
        end

        def won?
          return unless final?

          home? == (home[:runs] > away[:runs])
        end

        def lost?
          return unless final?

          home? == (home[:runs] < away[:runs])
        end

        def preview?
          @feed['gameData']['status']['abstractGameState'] == 'Preview'
        end

        def final?
          @feed['gameData']['status']['abstractGameState'] == 'Final'
        end
        alias over? final?

        def live?
          !(preview? || final?)
        end

        def started?
          !preview?
        end

        def inning
          return @feed['gameData']['status']['detailedState'] unless live?

          "#{@feed.linescore['inningState']} of the " \
          "#{@feed.linescore['currentInningOrdinal']}"
        end

        def outs
          return unless live? && @feed.linescore

          @feed.linescore['outs']
        end

        def runners
          return '' unless live? && @feed.linescore&.dig('offense')

          bitmap = 0b000
          bitmap |= 0b001 if @feed.linescore.dig('offense', 'first')
          bitmap |= 0b010 if @feed.linescore.dig('offense', 'second')
          bitmap |= 0b100 if @feed.linescore.dig('offense', 'third')

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
