# frozen_string_literal: true

class Baseballbot
  module Template
    class Sidebar
      module TodaysGames
        PREGAME_STATUSES = /
          Preview|Warmup|Pre-Game|Delayed Start|Scheduled
        /x.freeze
        POSTGAME_STATUSES = /Final|Game Over|Postponed|Completed Early/.freeze

        def todays_games(date)
          @date = date || @subreddit.now

          load_game_threads

          scheduled_games.map { |game| process_todays_game game }
        end

        protected

        def scheduled_games
          @bot.api.schedule(
            sportId: 1,
            date: @date.strftime('%m/%d/%Y'),
            hydrate: 'game(content(summary)),linescore,flags,team'
          ).dig('dates', 0, 'games') || []
        end

        def process_todays_game(game)
          game_hash(game).tap { |data| mark_winner_and_loser(data) }
        end

        def game_hash(game)
          status = game.dig('status', 'abstractGameState')

          started = !PREGAME_STATUSES.match?(status)

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
            score: (started && team['score'] ? team['score'].to_i : '')
          }
        end

        def mark_winner_and_loser(data)
          started = !PREGAME_STATUSES.match?(data[:raw_status])

          return unless started && data[:home][:score] != data[:away][:score]

          home_team_winning = data[:home][:score] > data[:away][:score]
          winner, loser = home_team_winning ? %i[home away] : %i[away home]

          over = POSTGAME_STATUSES.match?(data[:raw_status])

          data[winner][:score] = bold data[winner][:score]
          data[loser][:score] = italic data[loser][:score] if over
        end

        def link_for_team(game:, team:)
          code = team.dig('team', 'abbreviation')

          # This is no longer included in the data - we might have to switch to
          # using game_pk instead.
          gid = [
            @date.strftime('%Y_%m_%d'),
            "#{game.dig('teams', 'away', 'team', 'teamCode')}mlb",
            "#{game.dig('teams', 'home', 'team', 'teamCode')}mlb",
            game['gameNumber']
          ].join('_')

          post_id = @game_threads["#{gid}_#{subreddit(code)}".downcase]

          return "[^★](/#{post_id} \"team-#{code.downcase}\")" if post_id

          "[][#{code}]"
        end

        def game_status(game)
          status = game.dig('status', 'detailedState')

          case status
          when 'In Progress' then game_inning game
          when 'Postponed' then italic 'PPD'
          when 'Delayed Start' then delay_type game
          when 'Delayed' then "#{delay_type game} #{game_inning game}"
          when 'Warmup' then 'Warmup'
          else
            pre_or_post_game_status(game, status)
          end
        end

        def pre_or_post_game_status(game, status)
          if POSTGAME_STATUSES.match?(status)
            innings = game.dig('linescore', 'currentInning')

            return innings == 9 ? 'F' : "F/#{innings}"
          end

          Baseballbot::Utility
            .parse_time(game['gameDate'], in_time_zone: @subreddit.timezone)
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

        def load_game_threads
          @game_threads = {}

          @bot.redis.keys(@date.strftime('%Y_%m_%d_*')).each do |key|
            # _, game_pk = key.split('_').last

            @bot.redis.hgetall(key).each do |subreddit, link_id|
              # @game_threads["#{game_pk}_#{subreddit}".downcase] = link_id
              @game_threads["#{key}_#{subreddit}".downcase] = link_id
            end
          end
        end
      end
    end
  end
end
