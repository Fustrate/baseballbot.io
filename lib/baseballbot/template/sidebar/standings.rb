class Baseballbot
  module Template
    class Sidebar
      module Standings
        STANDINGS = "http://mlb.mlb.com/lookup/json/named.standings_schedule_date.bam?season=%Y&schedule_game_date.game_date='%Y/%m/%d'&sit_code='h0'&league_id=103&league_id=104&all_star_sw='N'&version=2"

        def divisions
          @divisions ||= begin
            # Don't ask me, MLB started acting stupid one day
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

            determine_wildcards teams

            divisions = Hash.new { |hash, key| hash[key] = [] }

            teams.each do |_, team|
              # Sort by (in order) lowest losing %, most wins, least losses, code
              team[:sort_order] = [1.0 - team[:percent], 162 - team[:wins], team[:losses], team[:code]]

              divisions[team[:division_id]] << team
            end

            divisions.each do |id, division|
              divisions[id] = division.sort_by { |team| team[:sort_order] }
            end

            divisions
          end
        end

        def standings
          divisions[@team.division.id]
        end

        def full_standings
          @full_standings ||= {
            nl: divisions[203].zip(divisions[205], divisions[204]),
            al: divisions[200].zip(divisions[202], divisions[201])
          }
        end

        def determine_wildcards(teams)
          determine_league_wildcards teams, [203, 204, 205]
          determine_league_wildcards teams, [200, 201, 202]
        end

        def determine_league_wildcards(teams, division_ids)
          all_teams = teams.select do |code, team|
                        division_ids.include?(team[:division_id])
                      end.map { |ary| ary[1] }

          in_first, not_in_first = all_teams.partition { |team| team[:games_back] == 0 }

          number_of_spots = 5 - in_first.count

          return if number_of_spots == 0

          in_order = not_in_first.sort_by { |team| team[:wildcard_gb] }

          in_first = in_order.select { |team| team[:wildcard_gb] == in_order[0][:wildcard_gb] }

          in_first.each do |team|
            teams[team[:code].to_sym][:wildcard_position] = 1
          end

          # Only add the second wildcard(s) under certain conditions
          return unless in_first.count == 1 && number_of_spots == 2

          in_order.each do |team|
            next unless team[:wildcard_gb] == in_order[1][:wildcard_gb]

            teams[team[:code].to_sym][:wildcard_position] = 2
          end
        end

        def team_stats
          @team_stats ||= standings
                          .select { |team| team[:code] == @team.code }
                          .first
        end

        def [](stat)
          team_stats[stat]
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
            home_record:    row['home'].split('-'),
            road_record:    row['away'].split('-'),
            interleague:    row['interleague'],
            wildcard:       row['gb_wildcard'],
            wildcard_gb:    wildcard(row['gb_wildcard']),
            elim:           row['elim'],
            elim_wildcard:  row['elim_wildcard'],
            division_champ: %w(y z).include?(row['playoffs_flag_mlb']),
            wildcard_champ: %w(w x).include?(row['playoffs_flag_mlb']),
            division_id:    row['division_id'].to_i,
            team:           @bot.gameday.team(row['team_abbrev']),
            subreddit:      subreddit(row['team_abbrev'])
          }
        end
      end
    end
  end
end
