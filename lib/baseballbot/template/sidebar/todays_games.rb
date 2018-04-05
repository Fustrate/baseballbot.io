# frozen_string_literal: true

class Baseballbot
  module Template
    class Sidebar
      module TodaysGames
        SCHEDULE = \
          'https://statsapi.mlb.com/api/v1/schedule?sportId=1&date=%<date>s&' \
          'hydrate=game(content(summary)),linescore,flags,team'

        PREGAME_STATUSES = [
          'Preview', 'Warmup', 'Pre-Game', 'Delayed Start', 'Scheduled'
        ].freeze

        POSTGAME_STATUSES = [
          'Final', 'Game Over', 'Postponed', 'Completed Early'
        ].freeze

        def todays_games
          @date = @subreddit.timezone.now

          load_gamechats

          url = format(SCHEDULE, date: @date.strftime('%m/%d/%Y'))

          JSON.parse(URI.parse(url).open.read)
            .dig('dates', 0, 'games')
            .map { |game| process_todays_game game }
        end

        protected

        def process_todays_game(game)
          game_hash(game).tap { |data| mark_winner_and_loser(data) }
        end

        def game_hash(game)
          status = game.dig('status', 'abstractGameState')

          started = !PREGAME_STATUSES.include?(status)

          {
            home: team_data(game, 'home', started),
            away: team_data(game, 'away', started),
            raw_status: status,
            status: gameday_link(game_status(game), game['gamePk']),
            free: game.dig('content', 'media', 'freeGame')
          }
        end

        def team_data(game, flag, started)
          team = game.dig('teams', flag)

          {
            team: link_for_team(game: game, team: team),
            score: (started ? team['score'].to_i : '')
          }
        end

        def mark_winner_and_loser(data)
          started = !PREGAME_STATUSES.include?(data[:raw_status])

          return unless started && data[:home][:score] != data[:away][:score]

          home_team_winning = data[:home][:score] > data[:away][:score]
          winner, loser = home_team_winning ? %i[home away] : %i[away home]

          over = POSTGAME_STATUSES.include?(data[:raw_status])

          data[winner][:score] = bold data[winner][:score]
          data[loser][:score] = italic data[loser][:score] if over
        end

        def link_for_team(game:, team:)
          code = team_from_id(team.dig('team', 'id'))['abbreviation']

          gamechat = @gamechats["#{game['gamePk']}_#{subreddit code}".downcase]

          if gamechat
            "[^★](/#{gamechat} \"team-#{code.downcase}\")"
          else
            "[][#{code}]"
          end
        end

        def game_status(game)
          status = game.dig('status', 'detailedState')

          case status
          when 'In Progress'
            game_inning game
          when 'Postponed'
            italic game.dig('status', 'statusCode')
          when 'Delayed Start'
            delay_type game
          when 'Delayed'
            "#{delay_type game} #{game_inning game}"
          when 'Warmup'
            'Warmup'
          else
            pre_or_post_game_status(game, status)
          end
        end

        def pre_or_post_game_status(game, status)
          if POSTGAME_STATUSES.include?(status)
            innings = game.dig('linescore', 'currentInning')

            return innings == '9' ? 'F' : "F/#{innings}"
          end

          @subreddit.timezone
            .utc_to_local(Time.parse(game['gameDate']))
            .strftime('%-I:%M')
        end

        def delay_type(game)
          game.dig('status', 'reason') == 'Rain' ? '☂' : 'Delay'
        end

        def game_inning(game)
          (game.dig('linescore', 'isTopInning') ? '▲' : '▼') +
            bold(game.dig('linescore', 'currentInning'))
        end

        def gameday_link(text, game_pk)
          link_to text, url: "https://www.mlb.com/gameday/#{game_pk}"
        end

        def load_gamechats
          @gamechats = {}

          @bot.redis.keys("#{@date.strftime('%Y-%m-%d')}_*").each do |key|
            _, game_pk = key.split('_').last

            @bot.redis.hgetall(key).each do |subreddit, link_id|
              @gamechats["#{game_pk}_#{subreddit}".downcase] = link_id
            end
          end
        end
      end
    end
  end
end
