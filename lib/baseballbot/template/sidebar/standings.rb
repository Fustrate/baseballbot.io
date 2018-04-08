# frozen_string_literal: true

class Baseballbot
  module Template
    class Sidebar
      module Standings
        STANDINGS = 'http://mlb.mlb.com/lookup/json/named.standings_schedule_' \
                    'date.bam?season=%Y&schedule_game_date.game_date=\'' \
                    '%Y/%m/%d\'&sit_code=\'h0\'&league_id=103&league_id=104' \
                    '&all_star_sw=\'N\'&version=2'

        def divisions
          @divisions ||= begin
            teams = {}

            load_teams_from_remote.each do |team|
              teams[team['team_abbrev'].to_sym] = parse_standings_row(team)
            end

            determine_wildcards teams

            sort_teams_into_divisions(teams).each_value do |teams_in_division|
              teams_in_division.sort_by! { |team| team[:sort_order] }
            end
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

        def leagues
          @leagues ||= {
            nl: divisions[203] + divisions[204] + divisions[205],
            al: divisions[200] + divisions[201] + divisions[202]
          }
        end

        def draft_order
          @draft_order ||= divisions.values
            .flatten(1)
            .sort_by! { |team| team[:sort_order] }
            .reverse
        end

        def wildcards_in_league(league)
          wildcard_order(league).reject { |team| team[:games_back].zero? }
        end

        def wildcard_order(league)
          leagues[league].sort_by { |team| team[:wildcard_gb] }
        end

        def determine_wildcards(teams)
          determine_league_wildcards teams, [203, 204, 205]
          determine_league_wildcards teams, [200, 201, 202]
        end

        def determine_league_wildcards(teams, division_ids)
          eligible = teams_in_divisions(teams, division_ids)
            .sort_by { |team| team[:wildcard_gb] }

          first_and_second_wildcards(eligible)
            .each_with_index do |teams_in_spot, position|
              teams_in_spot.each do |team|
                teams[team[:code].to_sym][:wildcard_position] = position + 1
              end
            end
        end

        def team_stats
          @team_stats ||= standings.find { |team| team[:code] == @team.code }
        end

        def [](stat)
          team_stats[stat]
        end

        protected

        # rubocop:disable Metrics/MethodLength
        def parse_standings_row(row)
          {
            code:           row['team_abbrev'],
            division_champ: %w[y z].include?(row['playoffs_flag_mlb']),
            division_id:    row['division_id'].to_i,
            elim_wildcard:  row['elim_wildcard'],
            elim:           row['elim'],
            games_back:     row['gb'].to_f,
            home_record:    row['home'].split('-'),
            interleague:    row['interleague'],
            last_ten:       row['last_ten'],
            losses:         row['l'].to_i,
            percent:        row['pct'].to_f,
            road_record:    row['away'].split('-'),
            run_diff:       row['runs'].to_i - row['opp_runs'].to_i,
            streak:         row['streak'],
            subreddit:      subreddit(row['team_abbrev']),
            team:           @bot.gameday.team(row['team_abbrev']),
            wildcard_champ: %w[w x].include?(row['playoffs_flag_mlb']),
            wildcard_gb:    wildcard(row['gb_wildcard']),
            wildcard:       row['gb_wildcard'],
            wins:           row['w'].to_i
          }.tap do |team|
            # Used for sorting teams in the standings. Lowest losing %, most
            # wins, least losses, and then fall back to three letter code
            team[:sort_order] = [
              1.0 - team[:percent],
              162 - team[:wins],
              team[:losses],
              team[:code]
            ]
          end
        end
        # rubocop:enable Metrics/MethodLength

        def sort_teams_into_divisions(teams)
          Hash.new { |hash, key| hash[key] = [] }.tap do |divisions|
            teams.each_value { |team| divisions[team[:division_id]] << team }
          end
        end

        def teams_in_divisions(teams, ids)
          teams.values.keep_if { |team| ids.include?(team[:division_id]) }
        end

        # Take the eligible teams, remove all teams who aren't at least tied
        # with the team in 5th place, remove teams in first place, and then
        # split between teams ahead of the second spot
        #
        # This might put two teams tied for second instead of tied for first
        def first_and_second_wildcards(eligible)
          eligible
            .reject { |team| team[:wildcard_gb] > eligible[4][:wildcard_gb] }
            .reject { |team| team[:games_back].zero? }
            .partition { |team| team[:wildcard_gb].negative? }
        end

        def load_teams_from_remote
          # Don't ask me, MLB started acting stupid one day. Going back 4 hours
          # seems to fix the problem.
          filename = (Time.now - 4 * 3600).strftime STANDINGS

          JSON.parse(URI.parse(filename).open.read)
            .dig(
              'standings_schedule_date',
              'standings_all_date_rptr',
              'standings_all_date'
            )
            .flat_map { |league| league['queryResults']['row'] }
        end
      end
    end
  end
end
