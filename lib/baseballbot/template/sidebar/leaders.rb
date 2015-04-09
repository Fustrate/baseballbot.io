class Baseballbot
  module Template
    class Sidebar
      module Leaders
        LEADERS_BASE_URL = 'http://mlb.mlb.com/pubajax/wf/flow/stats.splayer?' \
                           'season=%{year}&sort_order=\'desc\'' \
                           '&page_type=SortablePlayer&team_id=%{team_id}' \
                           '&game_type=\'%{type}\'&player_pool=%{pool}' \
                           '&season_type=ANY&sport_code=\'mlb\'&results=1000' \
                           '&recSP=1&recPP=50'

        HITTER_URL  = "#{LEADERS_BASE_URL}&sort_column='avg'&stat_type=hitting"
        PITCHER_URL = "#{LEADERS_BASE_URL}&sort_column='era'&stat_type=pitching"

        # TODO: This method only allows for one year+type to be loaded before
        # being memoized. Cache into a hash instead?
        def hitter_stats(year: nil, type: 'R', count: 1)
          year ||= Date.today.year

          @hitter_stats ||= begin
            stats = {}
            all_hitters = hitters(year: year, type: type)
            qualifying = hitters(year: year, type: type, pool: 'QUALIFIER')

            %w(h xbh hr rbi bb sb r).each do |key|
              stats[key] = high_stat(key, all_hitters, count: count).map do |s|
                { name: s[0], value: s[1].to_i }
              end
            end

            %w(avg obp slg ops).each do |key|
              stats[key] = high_stat(key, qualifying, count: count).map do |s|
                { name: s[0], value: pct(s[1]) }
              end
            end

            stats
          end
        end

        # TODO: This method only allows for one year+type to be loaded before
        # being memoized. Cache into a hash instead?
        def pitcher_stats(year: nil, type: 'R', count: 1)
          year ||= Date.today.year

          @pitcher_stats ||= begin
            stats = {}
            all_pitchers = pitchers(year: year, type: type)
            qualifying = pitchers(year: year, type: type, pool: 'QUALIFIER')

            %w(w sv hld so).each do |key|
              stats[key] = high_stat(key, all_pitchers, count: count).map do |s|
                { name: s[0], value: s[1].to_i }
              end
            end

            stats['ip'] = high_stat('ip', all_pitchers, count: count).map do |s|
              { name: s[0], value: s[1] }
            end

            stats['avg'] = high_stat('avg', qualifying, count: count).map do |s|
              { name: s[0], value: pct(s[1]) }
            end

            %w(whip era).each do |key|
              stats[key] = low_stat(key, qualifying, count: 3).map do |s|
                { name: s[0], value: s[1].to_s.sub(/\A0+/, '') }
              end
            end

            stats
          end
        end

        protected

        def high_stat(key, players, count: 1)
          return [['', 0]] unless players

          players
            .map { |player| player.values_at 'name_display_last_init', key }
            .sort_by { |player| player[1].to_f }
            .reverse
            .first count
        end

        def low_stat(key, players, count: 1)
          return [['', 0]] unless players

          players
            .map { |player| player.values_at 'name_display_last_init', key }
            .sort_by { |player| player[1].to_f }
            .first count
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
          json = JSON.load(data)
          players = json['stats_sortable_player']['queryResults']['row']

          # Array(players) doesn't work because hashes have a #to_a method
          players.is_a?(Hash) ? [players] : players
        end
      end
    end
  end
end
