# frozen_string_literal: true

class Baseballbot
  module Template
    class Sidebar
      module TodaysGames
        GD2 = 'http://gd2.mlb.com/components/game/mlb'

        SCOREBOARD_URL = "#{GD2}/year_%Y/month_%m/day_%d/miniscoreboard.xml"

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
          status = game.xpath('@status').text
          gid = game.xpath('@gameday_link').text

          started = !PREGAME_STATUSES.include?(status)
          over = POSTGAME_STATUSES.include?(status)

          home_score = started ? game.xpath('@home_team_runs').text.to_i : ''
          away_score = started ? game.xpath('@away_team_runs').text.to_i : ''

          {
            home: {
              team: link_for_team(game: game, team: 'home'),
              score: home_score
            },
            away: {
              team: link_for_team(game: game, team: 'away'),
              score: away_score
            },
            status: gameday_link(game_status(game), gid),
            free: game.xpath('game_media/media[@free="ALL"]').any?
          }.tap do |data|
            if started && home_score != away_score
              w, l = home_score > away_score ? %i(home away) : %i(away home)

              data[w][:score] = bold data[w][:score]
              data[l][:score] = italic data[l][:score] if over
            end
          end
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

          return game_inning game if status == 'In Progress'
          return italic game.xpath('@ind').text if status == 'Postponed'
          return delay_type game if status == 'Delayed Start'
          return "#{delay_type game} #{game_inning game}" if status == 'Delayed'
          return 'Warmup' if status == 'Warmup'

          if POSTGAME_STATUSES.include?(status)
            innings = game.xpath('@inning').text

            return innings == '9' ? 'F' : "F/#{innings}"
          end

          game.xpath('@time').text
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
