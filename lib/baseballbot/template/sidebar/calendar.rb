class Baseballbot
  module Template
    class Sidebar
      module Calendar
        # Date#days_in_month
        using TemplateRefinements

        CALENDAR_DATA_URL = 'http://mlb.mlb.com/lookup/json/named.schedule_' \
                            "team_sponsors.bam?start_date='%{start_date}'&" \
                            "end_date='%{end_date}'&team_id=%{team_id}&" \
                            "season=%{year}&game_type='R'&game_type='A'&" \
                            "game_type='E'&game_type='F'&game_type='D'&" \
                            "game_type='L'&game_type='W'&game_type='C'&" \
                            "game_type='S'"

        # See #calendar for month options
        def month_calendar(month = nil, options = {})
          days = calendar(month)

          first_day = days[days.keys.first]

          str = "S|M|T|W|T|F|S\n"
          str << ":-:|:-:|:-:|:-:|:-:|:-:|:-:\n"
          str << ' |' * first_day[:date].wday

          add_days_to_calendar(days, str, options)

          str
        end

        # Options are :last, :next, a Date, or nil (the current month)
        def calendar(month = nil)
          date = date_for_month(month)

          days = {}

          1.upto(date.days_in_month).each do |day|
            days[day] = {
              date: Date.new(date.year, date.month, day),
              games: []
            }
          end

          calendar_games(date).each do |game|
            next unless game['game_id']

            # Things like the ASG
            next unless game['team_file_code'] == @team.file_code

            date = Chronic.parse(game['team_game_time'])

            days[date.day][:games] << process_game(game, date)
          end

          days
        end

        def month_games
          calendar.flat_map { |_, day| day[:games] }
        end

        def previous_games(limit)
          return @previous.first(limit) if @previous && @previous.count >= limit

          @previous = []

          [:current, :previous].each do |month|
            Hash[calendar(month).to_a.reverse].each do |_, day|
              next if day[:date] > Date.today

              day[:games].each { |game| @previous << game if game[:over] }

              break if @previous.count >= limit
            end
          end

          @previous.first(limit)
        end

        def upcoming_games(limit)
          return @upcoming.first(limit) if @upcoming && @upcoming.count >= limit

          @upcoming = []

          [:current, :next].each do |month|
            calendar(month).each do |_, day|
              next if day[:date] < Date.today

              day[:games].each { |game| @upcoming << game unless game[:over] }

              break if @upcoming.count >= limit
            end
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

        def cell(cnum, games, options = {})
          str = "^#{cnum} "

          return str.strip if games.empty?

          # Let's hope nobody plays a doubleheader against two different teams
          subreddit = subreddit games.first[:opponent].code

          # Spring training games sometimes are against colleges
          subreddit.downcase! if subreddit && options[:downcase]

          statuses = games.map { |game| game[:status] }

          str << link_to('', sub: subreddit, title: statuses.join(', '))

          games[0][:home] ? (bold str) : (italic str)
        end

        def build_team(code:, name:)
          @bot.gameday.team(code) ||
            MLBGameday::Team.new(name: name, code: code)
        end

        def date_for_month(month)
          if month == :last
            Date.today.last_month
          elsif month == :next
            Date.today.next_month
          elsif month.is_a? Date
            month
          else
            Date.today
          end
        end

        def outcome(game)
          return 'Tied' if game[:score][0] == game[:score][1]

          return 'Won' if game[:score][0] > game[:score][1]

          'Lost'
        end

        def process_game(game, date)
          post_process_game(
            date: date,
            home: game['home_away_sw'] == 'H',
            opponent: build_team(code: game['opponent_abbrev'],
                                 name: game['opponent_brief']),
            over: %w(F C D FT FR).include?(game['game_status_ind']),
            score: [game['team_score'].to_i, game['opponent_score'].to_i],
            tv: game['team_tv'] || '',
            status_code: game['game_status_ind']
          )
        end

        # Values that depend on other values in the hash
        def post_process_game(game)
          game[:outcome] = outcome(game) if game[:over]
          game[:status] = calendar_game_status game

          game
        end

        def calendar_games(date)
          calendar_data(date)['schedule_team_sponsors'] \
            ['schedule_team_complete']['queryResults']['row']
        end

        def calendar_data(date)
          start_date = Date.civil(date.year, date.month, 1).strftime('%Y/%m/%d')
          end_date = Date.civil(date.year, date.month, -1).strftime('%Y/%m/%d')

          JSON.load open_url(CALENDAR_DATA_URL,
                             year: date.year,
                             start_date: start_date,
                             end_date: end_date)
        end

        def add_days_to_calendar(days, calendar, options = {})
          days_in_month = first_day.days_in_month

          days.each do |cday, day|
            calendar << cell(cday, day[:games], downcase: options[:downcase])

            if !day[:date].saturday?
              calendar << '|'
            elsif day[:date].day != days_in_month
              calendar << "\n"
            end
          end
        end

        def calendar_game_status(game)
          return 'Delayed' if game[:status_code] == 'D'

          return "#{game[:outcome]} #{game[:score].join '-'}" if game[:over]

          return game[:date].strftime '%-I:%M' if game[:tv].empty?

          game[:date].strftime "%-I:%M, #{game[:tv]}"
        end
      end
    end
  end
end
