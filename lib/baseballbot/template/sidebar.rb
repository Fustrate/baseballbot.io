class Baseballbot
  module Template
    class Sidebar < Base
      HITTER_DATA_URL  = "http://mlb.mlb.com/pubajax/wf/flow/stats.splayer?season=%{year}&sort_order='desc'&sort_column='avg'&stat_type=hitting&page_type=SortablePlayer&team_id=%{team_id}&game_type='%{type}'&player_pool=%{pool}&season_type=ANY&sport_code='mlb'&results=1000&recSP=1&recPP=50"
      PITCHER_DATA_URL = "http://mlb.mlb.com/pubajax/wf/flow/stats.splayer?season=%{year}&sort_order='desc'&sort_column='era'&stat_type=pitching&page_type=SortablePlayer&team_id=%{team_id}&game_type='%{type}'&player_pool=%{pool}&season_type=ANY&sport_code='mlb'&results=1000&recSP=1&recPP=50"
      CALENDAR_DATA_URL = "http://mlb.mlb.com/lookup/json/named.schedule_team_sponsors.bam?start_date='%{start_date}'&end_date='%{end_date}'&team_id=%{team_id}&season=%{year}&game_type='A'&game_type='E'&game_type='F'&game_type='D'&game_type='L'&game_type='W'&game_type='C'&game_type='S'"
      STANDINGS = "http://mlb.mlb.com/lookup/json/named.standings_schedule_date.bam?season=%Y&schedule_game_date.game_date='%Y/%m/%d'&sit_code='h0'&league_id=103&league_id=104&all_star_sw='N'&version=2"

      class << self
        def divisions
          @divisions ||= begin
            # Don't ask me, MLB was acting stupid one day
            filename = (Time.now - 4 * 3600).strftime STANDINGS

            standings = JSON.parse open(filename).read
            standings = standings['standings_schedule_date']
            standings = standings['standings_all_date_rptr']['standings_all_date']

            teams = {}

            standings.each do |league|
              league['queryResults']['row'].each do |row|
                teams[row['team_abbrev'].to_sym] = parse_standings_row(row)
              end
            end

            divisions = Hash.new { |hash, key| hash[key] = [] }

            teams.each do |_, team|
              divisions[team[:division_id]] << team
            end

            divisions.each do |id, division|
              divisions[id] = division.sort_by do |team|
                # Sort by (in order) lowest losing %, most wins, least losses, code
                [1.0 - team[:percent], 162 - team[:wins], team[:losses], team[:code]]
              end
            end

            divisions
          end
        end

        protected

        def parse_standings_row(row)
          {
            code:           row['team_abbrev'],
            wins:           row['w'].to_i,
            losses:         row['l'].to_i,
            games_back:     row['gb'].to_f,
            percent:        row['pct'].to_f,
            last_ten:       row['last_ten'],
            streak:         row['streak'],
            run_diff:       row['runs'].to_i - row['opp_runs'].to_i,
            home:           row['home'],
            road:           row['away'],
            interleague:    row['interleague'],
            wildcard:       row['gb_wildcard'],
            wildcard_gb:    wildcard(row['gb_wildcard']),
            elim:           row['elim'],
            elim_wildcard:  row['elim_wildcard'],
            division_champ: %w(y z).include?(row['playoffs_flag_mlb']),
            wildcard_champ: %w(w x).include?(row['playoffs_flag_mlb']),
            division_id:    row['division_id'].to_i
          }
        end

        def wildcard(wcgb)
          wcgb.to_f * (wcgb[0] == '+' ? -1 : 1)
        end
      end

      def initialize(body:, bot:, subreddit:)
        super(body: body, bot: bot)

        @subreddit = subreddit
        @team = @subreddit.team
      end

      def standings
        self.class.divisions[@team.division.id].map do |team|
          team[:team] = @bot.gameday.team(team[:code])
        end

        self.class.divisions[@team.division.id]
      end

      def calendar_cell(cnum, games, options = {})
        str = "^#{cnum} "

        return str.strip if games.empty?

        # Let's hope nobody plays a doubleheader against two different teams
        subreddit = subreddit games.first[:opponent].code
        subreddit.downcase! if options[:downcase]

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
            over: %w(F C D FT).include?(day['game_status_ind']),
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

      # TODO: This method only allows for one year+type to be loaded before
      # being memoized. Cache into a hash instead?
      def hitter_stats(year: nil, type: 'R')
        year ||= Date.today.year

        @hitter_stats ||= begin
          stats = {}
          all_hitters = hitters(year: year, type: type)
          qualifying = hitters(year: year, type: type, pool: 'QUALIFIER')

          %w(h xbh hr rbi bb sb r).each do |key|
            best = high_stat(key, all_hitters)

            stats[key] = { name: best[0], value: best[1].to_i }
          end

          %w(avg obp slg ops).each do |key|
            best = high_stat(key, qualifying)

            stats[key] = { name: best[0], value: pct(best[1]) }
          end

          stats
        end
      end

      # TODO: This method only allows for one year+type to be loaded before
      # being memoized. Cache into a hash instead?
      def pitcher_stats(year: nil, type: 'R')
        year ||= Date.today.year

        @pitcher_stats ||= begin
          stats = {}
          all_pitchers = pitchers(year: year, type: type)
          qualifying = pitchers(year: year, type: type, pool: 'QUALIFIER')

          %w(w sv hld so).each do |key|
            best = high_stat(key, all_pitchers)

            stats[key] = { name: best[0], value: best[1].to_i }
          end

          best = high_stat('ip', all_pitchers)

          stats['ip'] = { name: best[0], value: best[1] }

          best = low_stat('avg', qualifying)

          stats['avg'] = { name: best[0], value: pct(best[1]) }

          %w(whip era).each do |key|
            best = low_stat(key, qualifying)

            stats[key] = { name: best[0], value: best[1].to_s.sub(/\A0+/, '') }
          end

          stats
        end
      end

      def last_game
        return @last_game if @last_game

        date = Date.today + (24 * 3600)

        10.times do
          date -= (24 * 3600)

          begin
            games = gameday.find_games team: @team, date: date
          rescue OpenURI::HTTPError
            games = nil
          end

          next unless games

          games.each do |game|
            next unless game.over?

            @last_game = game

            return @last_game
          end
        end

        nil
      end

      def last_game_str(date_format: '%-m/%-d')
        game = last_game

        return '???' unless game

        if game.home_team.code == @team.code
          "#{game.date.strftime(date_format)} #{game.home_team.name} " \
          "#{game.score[0]} #{game.away_team.name} #{game.score[1]}"
        else
          "#{game.date.strftime(date_format)} #{game.away_team.name} " \
          "#{game.score[1]} #{game.home_team.name} #{game.score[0]}"
        end
      end

      def next_game
        return @next_game if @next_game

        date = Date.today - (24 * 3600)

        10.times do
          date += (24 * 3600)

          begin
            games = gameday.find_games team: @team, date: date
          rescue OpenURI::HTTPError
            games = nil
          end

          next unless games

          games.each do |game|
            next if game.over?

            @next_game = game

            return @next_game
          end
        end
      end

      def next_game_str(date_format: '%-m/%-d')
        game = next_game

        return '???' unless game

        if game.home_team.code == @team.code
          "#{game.date.strftime(date_format)} #{game.home_team.name} vs. " \
          "#{game.away_team.name} #{game.home_start_time}"
        else
          "#{game.date.strftime(date_format)} #{game.away_team.name} @ " \
          "#{game.home_team.name} #{game.away_start_time}"
        end
      end

      protected

      def high_stat(key, players)
        return ['', 0] unless players

        stats = players.map do |p|
          p.values_at('name_display_first_last', key)
        end

        highest = [stats.first[0], stats.first[1].to_f]

        stats.each do |stat|
          highest = [stat[0], stat[1].to_f] if stat[1].to_f > highest[1]
        end

        highest
      end

      def low_stat(key, players)
        return ['', 0] unless players

        stats = players.map do |p|
          p.values_at('name_display_first_last', key)
        end

        lowest = [stats.first[0], stats.first[1].to_f]

        stats.each do |stat|
          lowest = [stat[0], stat[1].to_f] if stat[1].to_f < lowest[1]
        end

        lowest
      end

      def hitters(year:, type:, pool: 'ALL')
        year ||= Date.today.year

        data = open_url(HITTER_DATA_URL, year: year, pool: pool, type: type)

        parse_player_data data
      end

      def pitchers(year:, type:, pool: 'ALL')
        year ||= Date.today.year

        data = open_url(PITCHER_DATA_URL, year: year, pool: pool, type: type)

        parse_player_data data
      end

      def parse_player_data(data)
        players = JSON.load(data)['stats_sortable_player']['queryResults']['row']

        players = [players] if players.is_a? Hash

        players
      end

      def build_team(code:, name:)
        @bot.gameday.team(code) || MLBGameday::Team.new(name: name, code: code)
      end

      def wildcard(wcgb)
        wcgb.to_f * (wcgb[0] == '+' ? -1 : 1)
      end

      def open_url(url, interpolations = {})
        interpolations.merge! team_id: @subreddit.team.id,
                              team_code: @subreddit.team.file_code

        open format(url, interpolations)
      end
    end
  end
end
