class Baseballbot
  module Template
    class Sidebar
      module Leaders
        HITTER_DATA_URL  = "http://mlb.mlb.com/pubajax/wf/flow/stats.splayer?season=%{year}&sort_order='desc'&sort_column='avg'&stat_type=hitting&page_type=SortablePlayer&team_id=%{team_id}&game_type='%{type}'&player_pool=%{pool}&season_type=ANY&sport_code='mlb'&results=1000&recSP=1&recPP=50"
        PITCHER_DATA_URL = "http://mlb.mlb.com/pubajax/wf/flow/stats.splayer?season=%{year}&sort_order='desc'&sort_column='era'&stat_type=pitching&page_type=SortablePlayer&team_id=%{team_id}&game_type='%{type}'&player_pool=%{pool}&season_type=ANY&sport_code='mlb'&results=1000&recSP=1&recPP=50"

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
          json = JSON.load(data)
          players = json['stats_sortable_player']['queryResults']['row']

          # Array(players) doesn't work because hashes have a #to_a method
          players.is_a?(Hash) ? [players] : players
        end
      end
    end
  end
end
