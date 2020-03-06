# frozen_string_literal: true

class Baseballbot
  module Template
    class Sidebar
      module Leaders
        LEADERS_BASE_URL = 'http://mlb.mlb.com/pubajax/wf/flow/stats.splayer?' \
                           'season=%<year>d&sort_order=\'desc\'' \
                           '&page_type=SortablePlayer&team_id=%<team_id>d' \
                           '&game_type=\'%<type>s\'&player_pool=%<pool>s' \
                           '&season_type=ANY&sport_code=\'mlb\'&results=1000' \
                           '&recSP=1&recPP=50'

        HITTER_URL  = "#{LEADERS_BASE_URL}&sort_column='avg'&stat_type=hitting"
        PITCHER_URL = "#{LEADERS_BASE_URL}&sort_column='era'&stat_type=pitching"

        def hitter_stats(year: nil, type: 'R', count: 1)
          year ||= Date.today.year

          @hitter_stats ||= {}

          key = [year, type, count].join('-')

          @hitter_stats[key] ||= load_hitter_stats(year, type, count)
        end

        def pitcher_stats(year: nil, type: 'R', count: 1)
          year ||= Date.today.year

          @pitcher_stats ||= {}

          key = [year, type, count].join('-')

          @pitcher_stats[key] ||= load_pitcher_stats(year, type, count)
        end

        def hitter_stats_table(stats: [])
          rows = stats.map do |stat|
            "#{stat.upcase}|#{hitter_stats[stat].first.values.join('|')}"
          end

          <<~TABLE
            Stat|Player|Total
            -|-|-
            #{rows.join("\n")}
          TABLE
        end

        def pitcher_stats_table(stats: [])
          rows = stats.map do |stat|
            "#{stat.upcase}|#{pitcher_stats[stat].first.values.join('|')}"
          end

          <<~TABLE
            Stat|Player|Total
            -|-|-
            #{rows.join("\n")}
          TABLE
        end

        protected

        def load_hitter_stats(year, type, count)
          stats = {}
          all_hitters = hitters(year: year, type: type)
          qualifying = hitters(year: year, type: type, pool: 'QUALIFIER')

          %w[h xbh hr rbi bb sb r].each do |key|
            stats[key] = list_of(key, all_hitters, 'high', count, :integer)
          end

          %w[avg obp slg ops].each do |key|
            stats[key] = list_of(key, qualifying, 'high', count, :float)
          end

          stats
        end

        def load_pitcher_stats(year, type, count)
          all_pitchers = pitchers(year: year, type: type)
          qualifying = pitchers(year: year, type: type, pool: 'QUALIFIER')

          stats = { 'ip' => list_of('ip', all_pitchers, 'high', count) }

          %w[w sv hld so].each do |key|
            stats[key] = list_of(key, all_pitchers, 'high', count, :integer)
          end

          %w[whip era avg].each do |key|
            stats[key] = list_of(key, qualifying, 'low', count, :float)
          end

          stats
        end

        def list_of(key, players, direction, count, type = :noop)
          return [{ name: '', value: 0 }] unless players

          players
            .map { |player| player.values_at 'name_display_last_init', key }
            .sort_by { |player| player[1].to_f }
            .send(direction == 'high' ? :reverse : :itself)
            .first(count)
            .map { |s| { name: s[0], value: cast_value(s[1], type) } }
        end

        def cast_value(value, type)
          return value.to_i if type == :integer
          return pct(value) if type == :float

          value
        end

        def hitters(year:, type:, pool: 'ALL')
          parse_player_data(
            open_url(HITTER_URL, year: year, pool: pool, type: type)
          )
        end

        def pitchers(year:, type:, pool: 'ALL')
          parse_player_data(
            open_url(PITCHER_URL, year: year, pool: pool, type: type)
          )
        end

        def parse_player_data(data)
          json = JSON.parse(data)
          players = json.dig('stats_sortable_player', 'queryResults', 'row')

          # Array(players) doesn't work because hashes have a #to_a method
          players.is_a?(Hash) ? [players] : players
        end

        def open_url(url, interpolations = {})
          interpolations[:team_id] = @subreddit.team.id

          URI.parse(format(url, interpolations)).open.read
        end
      end
    end
  end
end
