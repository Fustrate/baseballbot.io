# frozen_string_literal: true

class Baseballbot
  module Template
    class Sidebar
      module Standings
        STATS_STANDINGS = \
          'https://statsapi.mlb.com/api/v1/standings/regularSeason?' \
          'leagueId=103,104&season=%<year>d&date=%<date>s'

        def all_teams
          return @all_teams if @all_teams

          @all_teams = []

          load_divisions_from_remote.each do |division|
            division['teamRecords'].each do |team|
              data = parse_standings_row(division, team)

              @all_teams << data
            end
          end

          @all_teams.sort_by! { |team| team[:sort_order] }

          determine_league_wildcards(103)
          determine_league_wildcards(104)

          @all_teams
        end

        def standings
          all_teams.select { |team| team[:division_id] == @team.division_id }
        end

        def full_standings
          @full_standings ||= {
            al: all_teams.select { |team| team[:league_id] == 103 },
            nl: all_teams.select { |team| team[:league_id] == 104 }
          }
        end
        alias leagues full_standings

        def draft_order
          @draft_order ||= all_teams
            .sort_by! { |team| team[:sort_order] }
            .reverse
        end

        def teams_in_league(league_id)
          all_teams.select { |team| team[:league_id] == league_id }
        end

        def wildcards_in_league(league_id)
          teams_in_league(league_id)
            .reject { |team| team[:games_back] == '-' }
            .sort_by! { |team| team[:wildcard_gb].to_i }
        end

        def team_stats
          @team_stats ||= all_teams.find { |team| team[:team].id == @team.id }
        end

        protected

        # rubocop:disable Metrics/MethodLength
        def parse_standings_row(division, row)
          team = @bot.api.team(row['team']['id'])

          records = row.dig('records', 'splitRecords')
            .map { |rec| [rec['type'], [rec['wins'], rec['losses']]] }
            .to_h

          {
            id:             team.id,
            code:           team.abbreviation,
            # elim_wildcard:  row['elim_wildcard'],
            subreddit:      subreddit(team['abbreviation']),
            division_champ: row['divisionChamp'],
            division_id:    division['division']['id'],
            elim:           row['eliminationNumber'],
            games_back:     row['divisionGamesBack'],
            home_record:    records['home'],
            last_ten:       records['lastTen'],
            losses:         row['losses'],
            percent:        row['leagueRecord']['pct'].to_f,
            road_record:    records['road'],
            run_diff:       row['runDifferential'],
            streak:         row['streak']['streakCode'],
            team:           team,
            wildcard_champ: false,
            wildcard_gb:    row['wildCardGamesBack'],
            wildcard_rank:  row['wildCardRank'].to_i,
            wildcard:       row['hasWildcard'] && !row['divisionLeader'],
            wins:           row['wins']
          }.tap do |info|
            # Used for sorting teams in the standings. Lowest losing %, most
            # wins, least losses, and then fall back to three letter code
            info[:sort_order] = [
              1.0 - info[:percent],
              162 - info[:wins],
              info[:losses],
              info[:team]['abbreviation']
            ]
          end
        end
        # rubocop:enable Metrics/MethodLength

        # @!group Wildcards

        def determine_league_wildcards(league_id)
          eligible = teams_in_league(league_id)
            .sort_by { |team| team[:wildcard_gb] }

          # first_and_second_wildcards(eligible).each_with_index do |teams_in_spot, position|
          #   teams_in_spot.each do |team|
          #     teams[team[:code].to_sym][:wildcard_position] = position + 1
          #   end
          # end
        end

        # Take the eligible teams, remove all teams who aren't at least tied
        # with the team in 5th place, remove teams in first place, and then
        # split between teams ahead of the second spot
        #
        # This might put two teams tied for second instead of tied for first
        def first_and_second_wildcards(eligible)
          division_leaders_count = eligible
            .count { |team| team[:games_back] == '-' }

          # 5 or more division leaders means no wildcards
          return [] if division_leaders_count >= 5

          eligible
            .reject { |team| team[:wildcard_gb] == '-' }
            .reject { |team| team[:games_back] == '-' }
            .sort_by! { |team| team[:wildcard_rank] }
            .first(5 - division_leaders_count)
        end

        # @!endgroup Wildcards

        def load_divisions_from_remote
          filename = format(
            STATS_STANDINGS,
            year: Time.now.year,
            date: Time.now.strftime('%m/%d/%Y')
          )

          JSON.parse(URI.parse(filename).open.read).dig('records')
        end
      end
    end
  end
end
