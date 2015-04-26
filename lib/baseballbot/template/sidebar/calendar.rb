class Baseballbot
  module Template
    class Sidebar
      module Calendar
        CALENDAR_DATA_URL = "http://mlb.mlb.com/lookup/json/named.schedule_team_sponsors.bam?start_date='%{start_date}'&end_date='%{end_date}'&team_id=%{team_id}&season=%{year}&game_type='R'&game_type='A'&game_type='E'&game_type='F'&game_type='D'&game_type='L'&game_type='W'&game_type='C'&game_type='S'"

        def calendar_cell(cnum, games, options = {})
          str = "^#{cnum} "

          return str.strip if games.empty?

          # Let's hope nobody plays a doubleheader against two different teams
          subreddit = subreddit games.first[:opponent].code

          # Spring training games sometimes are against colleges
          subreddit.downcase! if subreddit && options[:downcase]

          statuses = games.map { |game| game[:status] }

          str << link_to('', sub: subreddit, title: statuses.join(', '))

          games.first[:home] ? (bold str) : (italic str)
        end

        # See #calendar for month options
        def month_calendar(month = nil, options = {})
          days = calendar(month)

          first_day = days[days.keys.first]

          str = "S|M|T|W|T|F|S\n"
          str << ":-:|:-:|:-:|:-:|:-:|:-:|:-:\n"
          str << ' |' * first_day[:date].wday

          days_in_month = Date.civil(first_day[:date].year,
                                     first_day[:date].month,
                                     -1).day

          days.each do |cday, day|
            str << calendar_cell(cday, day[:games], downcase: options[:downcase])

            if !day[:date].saturday?
              str << '|'
            elsif day[:date].day != days_in_month
              str << "\n"
            end
          end

          str
        end

        # Options are :last, :next, a Date, or nil (the current month)
        def calendar(month = nil)
          date = if month == :last
                   Date.today.last_month
                 elsif month == :next
                   Date.today.next_month
                 elsif month.is_a? Date
                   month
                 else
                   Date.today
                 end

          start_date = Date.civil(date.year, date.month, 1)
          end_date = Date.civil(date.year, date.month, -1)

          data = JSON.load open_url(CALENDAR_DATA_URL,
                                    year: date.year,
                                    start_date: start_date.strftime('%Y/%m/%d'),
                                    end_date: end_date.strftime('%Y/%m/%d'))

          days = {}

          days_in_month = end_date.day

          (1..days_in_month).each do |day|
            days[day] = {
              date: Date.new(date.year, date.month, day),
              games: []
            }
          end

          games = data['schedule_team_sponsors']['schedule_team_complete']
          games = games['queryResults']['row']

          games.each do |day|
            next unless day['game_id']

            # Things like the ASG
            next unless day['team_file_code'] == @team.file_code

            date = Chronic.parse(day['team_game_time'])

            days[date.day][:games] << {
              date: date,
              home: day['home_away_sw'] == 'H',
              opponent: build_team(code: day['opponent_abbrev'],
                                   name: day['opponent_brief']),
              over: %w(F C D FT FR).include?(day['game_status_ind']),
              score: [day['team_score'].to_i, day['opponent_score'].to_i],
              tv: day['team_tv'] || '',
              status_code: day['game_status_ind']
            }

            days[date.day][:games].each_with_index do |game, i|
              if game[:over]
                outcome = if game[:score][0] == game[:score][1]
                            'Tied'
                          elsif game[:score][0] > game[:score][1]
                            'Won'
                          else
                            'Lost'
                          end

                days[date.day][:games][i][:outcome] = outcome
              end

              days[date.day][:games][i][:status] = calendar_game_status game
            end
          end

          days
        end

        def month_games
          calendar.map { |_, day| day[:games] }.flatten(1)
        end

        def calendar_game_status(game)
          return 'Delayed' if game[:status_code] == 'D'

          if !game[:over]
            if game[:tv].empty?
              game[:date].strftime '%-I:%M'
            else
              game[:date].strftime "%-I:%M, #{game[:tv]}"
            end
          else
            "#{game[:outcome]} #{game[:score].join '-'}"
          end
        end

        def previous_games(limit)
          if @previous_games && @previous_games.count >= limit
            return @previous_games.first(limit)
          end

          @previous_games = []

          [:current, :previous].each do |month|
            Hash[calendar(month).to_a.reverse].each do |_, day|
              next if day[:date] > Date.today

              day[:games].each do |game|
                next unless game[:over]

                @previous_games << game
              end

              break if @previous_games.count >= limit
            end
          end

          @previous_games.first(limit)
        end

        def upcoming_games(limit)
          if @upcoming_games && @upcoming_games.count >= limit
            return @upcoming_games.first(limit)
          end

          @upcoming_games = []

          [:current, :next].each do |month|
            calendar(month).each do |_, day|
              next if day[:date] < Date.today

              day[:games].each do |game|
                next if game[:over]

                @upcoming_games << game
              end

              break if @upcoming_games.count >= limit
            end
          end

          @upcoming_games.first(limit)
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

        def build_team(code:, name:)
          @bot.gameday.team(code) || MLBGameday::Team.new(name: name, code: code)
        end
      end
    end
  end
end
