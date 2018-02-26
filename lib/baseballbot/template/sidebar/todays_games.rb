# frozen_string_literal: true

class Baseballbot
  module Template
    class Sidebar
      module TodaysGames
        GDX = 'http://gdx.mlb.com/components/game/mlb'

        SCOREBOARD_URL = "#{GDX}/year_%Y/month_%m/day_%d/miniscoreboard.xml"

        PREGAME_STATUSES = [
          'Preview', 'Warmup', 'Pre-Game', 'Delayed Start'
        ].freeze

        POSTGAME_STATUSES = [
          'Final', 'Game Over', 'Postponed', 'Completed Early'
        ].freeze

        def todays_games
          date = time.now - 10_800

          load_gamechats date

          Nokogiri::XML(open(date.strftime(SCOREBOARD_URL)))
            .xpath('//games/game')
            .map { |game| process_todays_game game }
        end

        protected

        def process_todays_game(game)
          game_hash(game).tap { |data| mark_winner_and_loser(data) }
        end

        def game_hash(game)
          status = game.xpath('@status').text
          gid = game.xpath('@gameday_link').text

          started = !PREGAME_STATUSES.include?(status)

          {
            home: {
              team: link_for_team(game: game, team: 'home'),
              score: (started ? game.xpath('@home_team_runs').text.to_i : '')
            },
            away: {
              team: link_for_team(game: game, team: 'away'),
              score: (started ? game.xpath('@away_team_runs').text.to_i : '')
            },
            raw_status: status,
            status: gameday_link(game_status(game), gid),
            free: game.xpath('game_media/media[@free="ALL"]').any?
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
          gid = game.xpath('@gameday_link').text
          code = game.xpath("@#{team}_name_abbrev").text

          gamechat = @gamechats["#{gid}_#{subreddit code}".downcase]

          if gamechat
            "[^★](/#{gamechat} \"team-#{code.downcase}\")"
          else
            "[][#{code}]"
          end
        end

        def game_status(game)
          status = game.xpath('@status').text

          case status
          when 'In Progress'
            game_inning game
          when 'Postponed'
            italic game.xpath('@ind').text
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
          unless POSTGAME_STATUSES.include?(status)
            return game.xpath('@time').text
          end

          innings = game.xpath('@inning').text

          innings == '9' ? 'F' : "F/#{innings}"
        end

        def delay_type(game)
          game.xpath('@reason').text == 'Rain' ? '☂' : 'Delay'
        end

        def game_inning(game)
          (game.xpath('@top_inning').text == 'Y' ? '▲' : '▼') +
            bold(game.xpath('@inning').text)
        end

        def gameday_link(text, gid)
          link_to text, url: "http://mlb.com/r/game?gid=#{gid}"
        end

        def load_gamechats(date)
          @gamechats = {}

          @bot.redis.keys(date.strftime('%Y_%m_%d_*')).each do |gid|
            @bot.redis.hgetall(gid).each do |subreddit, link_id|
              @gamechats["#{gid}_#{subreddit}".downcase] = link_id
            end
          end
        end
      end
    end
  end
end
