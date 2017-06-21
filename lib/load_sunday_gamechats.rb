# frozen_string_literal: true

# This file really needs to be cleaned up, as does the entire /lib/ directory.

require 'pg'
require 'json'
require 'open-uri'
require 'chronic'

@attempts = 0
@failures = 0

@timestamp = DateTime.now.strftime '%Y-%m-%d %H:%M:%S'

@conn = PG::Connection.new user: ENV['PG_USERNAME'],
                           dbname: ENV['PG_DATABASE'],
                           password: ENV['PG_PASSWORD']

R_BASEBALL_ID = 15
URL = 'http://gd2.mlb.com/components/game/mlb/year_%Y/month_%m/day_%d/' \
      'miniscoreboard.json'

def load_espn_game(date)
  data = JSON.parse open(date.strftime(URL)).read

  data.dig('data', 'games', 'game').each do |game|
    # Game time is not yet set or something is TBD
    next unless game['game_type'] == 'R' && game['tv_station'] == 'ESPN'

    gametime = Chronic.parse(
      "#{game['time_date_hm_lg']} PM #{game['home_time_zone']}"
    ) - 10_800

    next if gametime < Time.now

    insert_game game['gameday_link'], gametime
  end
end

def insert_game(gid, gametime)
  @attempts += 1

  @conn.exec_params(
    'INSERT INTO gamechats
      (gid, post_at, starts_at, status, created_at, updated_at, subreddit_id)
    VALUES
      ($1, $2, $3, \'Future\', $4, $5, $6)',
    [
      gid,
      (gametime - 3600).strftime('%Y-%m-%d %H:%M:%S'),
      gametime.strftime('%Y-%m-%d %H:%M:%S'),
      @timestamp,
      @timestamp,
      R_BASEBALL_ID
    ]
  )

  puts "+ #{gid}"
rescue PG::UniqueViolation
  @failures += 1

  puts "- #{gid}"
end

(0..4).each { |n| load_espn_game Chronic.parse("#{n} weeks from Sunday") }

puts "Added #{@attempts - @failures} of #{@attempts}"
