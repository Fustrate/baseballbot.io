class Baseballbot
  module Template
    class Sidebar
      module TodaysGames
        SCOREBOARD_URL = 'http://gd2.mlb.com/components/game/mlb/year_%Y/' \
                         'month_%m/day_%d/miniscoreboard.xml'
        def todays_games
          games = Nokogiri::XML open time.now.strftime SCOREBOARD_URL

          load_gamechats

          games.xpath('//games/game').map do |game|
            home_code = game.xpath('@home_name_abbrev').text
            home_subreddit = subreddit home_code

            away_code = game.xpath('@away_name_abbrev').text
            away_subreddit = subreddit away_code

            gid = game.xpath('@gameday_link').text

            started = !%w(Warmup Pre-Game).include?(game.xpath('@status').text)

            {
              gid: gid,
              home: link_for_team(code: home_code,
                                  subreddit: home_subreddit,
                                  gid: gid),
              home_runs: started ? game.xpath('@home_team_runs').text : '',
              away: link_for_team(code: away_code,
                                  subreddit: away_subreddit,
                                  gid: gid),
              away_runs: started ? game.xpath('@away_team_runs').text : '',
              status: status_for_game(game),
              free: game.xpath('game_media/media[@free="ALL"]').any?
            }.tap do |data|
              if data[:home_runs].empty?
                # Do nothing, the game hasn't started
              elsif data[:home_runs].to_i > data[:away_runs].to_i
                data[:home] = bold data[:home]
                data[:home_runs] = bold data[:home_runs]
              elsif data[:home_runs].to_i < data[:away_runs].to_i
                data[:away] = bold data[:away]
                data[:away_runs] = bold data[:away_runs]
              end
            end
          end
        end

        def link_for_team(code:, subreddit:, gid:)
          gamechat = @gamechats["#{gid}_#{subreddit}".downcase]

          if gamechat
            "[#{code} ^★](/#{gamechat} \"team-#{code.downcase}\")"
          else
            "[#{code}][#{code}]"
          end
        end

        protected

        def status_for_game(game)
          case game.xpath('@status').text
          when 'In Progress'
            (game.xpath('@top_inning').text == 'Y' ? '▲' : '▼') +
              bold(game.xpath('@inning').text)
          when 'Game Over'
            innings = game.xpath('@inning').text
            italic(innings == '9' ? 'F' : "F/#{innings}")
          when 'Final', 'Postponed'
            italic game.xpath('@ind').text
          when 'Warmup'
            'Warmup'
          else
            game.xpath('@time').text
          end
        end

        def load_gamechats
          @gamechats = {}

          # bots = {
          #   astros:           'astrosbot',
          #   nyyankees:        'yankeebot',
          #   phillies:         'philsbot',
          #   azdiamondbacks:   'snakebot',
          #   minnesotatwins:   'twinsgameday',
          #   motorcitykitties: 'tigersbot',
          #   kcroyals:         'royalsbot',
          #   padres:           'friarbot',
          #   orioles:          'osgamethreads',
          #   newyorkmets:      'metsbot',
          #   whitesox:         'chisoxbot',
          #   # Uses their own account
          #   cardinals:        'bravo_delta AND title:Game Cardinals',
          #   # Multiple authors
          #   buccos:           ' AND title:GDT',
          #   # reddit doesn't like this user as an author
          #   braves:           ' AND title:Game Thread Chief_Noc-A-Homa',
          # }
          #
          # queries = ['selftext:hellobaseballbot self:yes']

          @bot.redis.keys(time.now.strftime '%Y_%m_%d_*').each do |gid|
            @bot.redis.hgetall(gid).each do |subreddit, link_id|
              @gamechats["#{gid}_#{subreddit}".downcase] = link_id
              # bots.delete subreddit.to_sym
            end
          end

          # bots.map do |subreddit, bot|
          #   "(subreddit:#{subreddit} AND author:#{bot})"
          # end.each_slice(8) do |group|
          #   queries.unshift group.join ' OR '
          # end
          #
          # queries.each do |query|
          #   data = load_gamechats_from_query query
          #
          #   sleep 0.5
          #
          #   data.each do |item|
          #     date = Time.at(
          #       item['data']['created_utc'].to_i + 10_800
          #     ).to_datetime
          #
          #     next unless date.day == Date.today.day
          #
          #     subreddit = item['data']['subreddit'].downcase
          #     link_id = item['data']['id']
          #
          #     redis.hset hash_name, subreddit, link_id
          #
          #     gamechats[subreddit] ||= link_id
          #   end
          # end
        end

        def load_gamechats_from_query(query)
          url = 'http://www.reddit.com/user/BaseballBot/m/teams/search.json?' \
                "q=#{CGI.escape query}&sort=new&restrict_sr=on&limit=50&t=day"

          JSON.parse(open(url).read)['data']['children']
        end
      end
    end
  end
end
