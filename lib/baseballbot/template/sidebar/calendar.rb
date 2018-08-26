# frozen_string_literal: true

class Baseballbot
  module Template
    class Sidebar
      module Calendar
        SCHEDULE = \
          'http://statsapi.mlb.com/api/v1/schedule?teamId=%<team_id>d&' \
          'startDate=%<start_date>s&endDate=%<end_date>s&sportId=1&' \
          'eventTypes=primary&scheduleTypes=games&hydrate=team' \
          '(venue(timezone)),game(content(summary)),linescore,broadcasts(all)'

        def month_calendar(downcase: false)
          start_date = Date.civil(Date.today.year, Date.today.month, 1)
          end_date = Date.civil(Date.today.year, Date.today.month, -1)

          dates = calendar_games(start_date, end_date)

          cells = dates.map do |_, day|
            cell(day[:date].day, day[:games], downcase: downcase)
          end

          rows = [cells.shift(7 - dates.values.first[:date].wday).join('|')]

          rows << cells.shift(7).join('|') while cells.any?

          <<~TABLE
            S|M|T|W|T|F|S
            :-:|:-:|:-:|:-:|:-:|:-:|:-:
            #{' |' * dates.values.first[:date].wday}#{rows.join("\n")}
          TABLE
        end

        def month_games
          start_date = Date.civil(Date.today.year, Date.today.month, 1)
          end_date = Date.civil(Date.today.year, Date.today.month, -1)

          calendar_games(start_date, end_date).flat_map { |_, day| day[:games] }
        end

        def previous_games(limit)
          return @previous.first(limit) if @previous && @previous.count >= limit

          @previous = []

          # Go backwards an extra week to account for off days
          end_date = Date.today
          start_date = end_date - (7 * 86_400)

          calendar_games(start_date, end_date).each_value do |day|
            next if day[:date] > Date.today

            day[:games].each { |game| @previous << game if game[:over] }

            break if @previous.count >= limit
          end

          @previous.first(limit)
        end

        def upcoming_games(limit)
          return @upcoming.first(limit) if @upcoming && @upcoming.count >= limit

          @upcoming = []

          # Go forward an extra week to account for off days
          start_date = Date.today
          end_date = start_date + (7 * 86_400)

          calendar_games(start_date, end_date).each_value do |day|
            next if day[:date] < Date.today

            day[:games].each { |game| @upcoming << game unless game[:over] }

            break if @upcoming.count >= limit
          end

          @upcoming.first(limit)
        end

        def next_game
          upcoming_games(1)[0]
        end

        def next_game_str(date_format: '%-m/%-d')
          game = next_game

          return '???' unless game

          if game[:home]
            "#{game[:date].strftime(date_format)} #{@team.name} vs. " \
            "#{game[:opponent].name} #{game[:date].strftime('%-I:%M %p')}"
          else
            "#{game[:date].strftime(date_format)} #{@team.name} @ " \
            "#{game[:opponent].name} #{game[:date].strftime('%-I:%M %p')}"
          end
        end

        def last_game
          previous_games(1)[0]
        end

        def last_game_str(date_format: '%-m/%-d')
          game = last_game

          return '???' unless game

          "#{game[:date].strftime(date_format)} #{@team.name} " \
          "#{game[:score][0]} #{game[:opponent].name} #{game[:score][1]}"
        end

        protected

        def build_date_hash(start_date, end_date)
          days = {}

          start_date.upto(end_date).each do |day|
            days[day.strftime('%F')] = { date: day, games: [] }
          end

          days
        end

        def calendar_games(start_date, end_date)
          days = build_date_hash(start_date, end_date)

          calendar_dates(start_date, end_date).each do |calendar_date|
            calendar_date['games'].each do |game|
              next unless current_team_game?(game)

              date = Baseballbot.parse_time(
                game['gameDate'],
                in_time_zone: @subreddit.timezone
              )

              days[date.strftime('%F')][:games] << process_game(game, date)
            end
          end

          days
        end

        def current_team_game?(game)
          game.dig('teams', 'away', 'team', 'id') == @subreddit.team.id ||
            game.dig('teams', 'home', 'team', 'id') == @subreddit.team.id
        end

        def cell(date, games, options = {})
          num = "^#{date}"

          return num if games.empty?

          # Let's hope nobody plays a doubleheader against two different teams
          subreddit = subreddit games.first[:opponent].code

          # Spring training games sometimes are against colleges
          subreddit = subreddit.downcase if subreddit && options[:downcase]

          statuses = games.map { |game| game[:status] }

          link = link_to '', sub: subreddit, title: statuses.join(', ')

          games[0][:home] ? (bold "#{num} #{link}") : (italic "#{num} #{link}")
        end

        def build_team(id:, code:, name:)
          @bot.api.team(id) ||
            MLBStatsAPI::Team.new('teamName' => name, 'abbreviation' => code)
        end

        def outcome(game)
          return 'Tied' if game[:score][0] == game[:score][1]

          return 'Won' if game[:score][0] > game[:score][1]

          'Lost'
        end

        def process_game(game, date)
          team = game.dig('teams', home_team?(game) ? 'home' : 'away')
          opponent = game.dig('teams', home_team?(game) ? 'away' : 'home')

          info = {
            date: date,
            home: home_team?(game),
            opponent: game_opponent(game),
            score: [team['score'], opponent['score']],
            tv: tv_stations(game),
            status_code: game['status']['statusCode'],
            game_pk: game['gamePk']
          }

          info[:over] = %w[F C D FT FR].include? info[:status_code]
          info[:outcome] = outcome(info) if info[:over]
          info[:status] = calendar_game_status info
          info[:result] = game_result(info)

          info
        end

        def tv_stations(game)
          return '' unless game['broadcasts']

          home_away = home_team?(game) ? 'home' : 'away'

          game['broadcasts']
            .select { |broadcast| broadcast['type'] == 'TV' }
            .select { |broadcast| broadcast['language'] == 'en' }
            .select { |broadcast| broadcast['homeAway'] == home_away }
            .map { |broadcast| broadcast['callSign'] }
            .join(', ')
        end

        def game_result(game)
          return '' unless game[:over]

          return 'T' if game[:score][0] == game[:score][1]

          return 'W' if game[:score][0] > game[:score][1]

          'L'
        end

        def game_opponent(game)
          @bot.api.team(
            game.dig('teams', home_team?(game) ? 'away' : 'home', 'team', 'id')
          )
        end

        def home_team?(game)
          game.dig('teams', 'away', 'team', 'id') != @subreddit.team&.id
        end

        def calendar_dates(start_date, end_date)
          url = format(
            SCHEDULE,
            team_id: @subreddit.team.id,
            start_date: start_date.strftime('%m/%d/%Y'),
            end_date: end_date.strftime('%m/%d/%Y')
          )

          JSON.parse(URI.parse(url).open.read).dig('dates')
        end

        def calendar_game_status(game)
          return 'Delayed' if game[:status_code].start_with? 'D'

          return "#{game[:outcome]} #{game[:score].join '-'}" if game[:over]

          return game[:date].strftime '%-I:%M' if game[:tv].empty?

          game[:date].strftime "%-I:%M, #{game[:tv]}"
        end
      end
    end
  end
end
