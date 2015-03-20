class Baseballbot
  module Template
    class Sidebar < Base
      HITTER_DATA_URL  = "http://mlb.mlb.com/pubajax/wf/flow/stats.splayer?season=%{year}&sort_order='desc'&sort_column='avg'&stat_type=hitting&page_type=SortablePlayer&team_id=%{team_id}&game_type='%{type}'&player_pool=%{pool}&season_type=ANY&sport_code='mlb'&results=1000&recSP=1&recPP=50"
      PITCHER_DATA_URL = "http://mlb.mlb.com/pubajax/wf/flow/stats.splayer?season=%{year}&sort_order='desc'&sort_column='era'&stat_type=pitching&page_type=SortablePlayer&team_id=%{team_id}&game_type='%{type}'&player_pool=%{pool}&season_type=ANY&sport_code='mlb'&results=1000&recSP=1&recPP=50"
      CALENDAR_DATA_URL = 'http://mlb.mlb.com/gen/schedule/%{team_code}/%{year}_%{month}.json'
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

      def calendar_cell(cnum, day)
        str = "^#{cnum} "

        return str.strip unless day[:opponent]

        str << link_to('', sub: subreddit(day[:opponent].code), title: day[:status])

        day[:home] ? (bold str) : (italic str)
      end

      # See #calendar for month options
      def month_calendar(month = nil)
        days = calendar(month)

        first_day = days[days.keys.first]

        str = "S|M|T|W|T|F|S\n"
        str << ":-:|:-:|:-:|:-:|:-:|:-:|:-:\n"
        str << ' |' * first_day[:date].wday

        days_in_month = Date.civil(first_day[:date].year,
                                   first_day[:date].month,
                                   -1).day

        days.each do |cday, day|
          str << calendar_cell(cday, day)

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

        data = JSON.load open_url(CALENDAR_DATA_URL,
                                  month: date.month,
                                  year: date.year)

        days = {}

        days_in_month = Date.civil(date.year, date.month, -1).day

        (1..days_in_month).each do |day|
          days[day] = {
            date: Date.new(date.year, date.month, day)
          }
        end

        data.each do |day|
          next unless day['game_id']

          over = %w(F C D).include? day['game_status']

          if day['home']['file_code'] == @team.file_code
            home = true
            date = Chronic.parse(day['home']['start_time_local'])
            opponent = build_team(code: day['away']['display_code'],
                                  name: day['away']['full'])
            our_runs = day['home']['runs'].to_i
            their_runs = day['away']['runs'].to_i
            tv = day['home']['tv'].to_s
          elsif day['away']['file_code'] == @team.file_code
            home = false
            date = Chronic.parse(day['away']['start_time_local'])
            opponent = build_team(code: day['home']['display_code'],
                                  name: day['home']['full'])
            our_runs = day['away']['runs'].to_i
            their_runs = day['home']['runs'].to_i
            tv = day['away']['tv'].to_s
          else
            # Things like the ASG
            next
          end

          status = if day['game_status'] == 'D'
                     'Delayed'
                   elsif over
                     if our_runs > their_runs
                       "Won #{our_runs}-#{their_runs}"
                     else
                       "Lost #{our_runs}-#{their_runs}"
                     end
                   elsif !tv.empty?
                     date.strftime "%-I:%M, #{tv}"
                   else
                     date.strftime '%-I:%M'
                   end

          days[date.day] = {
            date: date,
            home: home,
            opponent: opponent,
            over: over,
            our_runs: our_runs,
            their_runs: their_runs,
            status: status,
            won: over ? our_runs > their_runs : nil
          }
        end

        days
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
