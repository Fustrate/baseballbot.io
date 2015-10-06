# This file really needs to be cleaned up, as does the entire /lib/ directory.

require 'pg'
require 'json'
require 'open-uri'
require 'chronic'

@attempts = 0
@failures = 0

@right_now = DateTime.now.strftime '%Y-%m-%d %H:%M:%S'

@conn = PG::Connection.new user: ENV['PG_USERNAME'],
                           dbname: ENV['PG_DATABASE'],
                           password: ENV['PG_PASSWORD']

URL = 'http://m.mlb.com/gdcross/components/game/mlb/year_2015/postseason_scoreboard.json'

def game_title(row)
  if row['game_type'] == 'F'
    return "Game Thread: #{row['series']} ⚾ #{row['away_team_name']} @ " \
           "#{row['home_team_name']} - #{row['first_pitch_et']} PM ET"
  end

  "Game Thread: #{row['description']} ⚾ #{row['away_team_name']} (0) " \
  " @ #{row['home_team_name']} (0) - #{row['first_pitch_et']} PM ET"
end

def load_schedule
  data = JSON.parse open(URL).read

  data['games'].each do |game|
    # Game time is not yet set or something is TBD
    next if game['time'] == '3:33' || game['tbd_flag'] == 'Y'
    # If the team is undetermined, their division will be blank
    next if game['home_division'] == '' || game['away_division'] == ''

    gametime = Chronic.parse(" #{game['original_date']} #{game['first_pitch_et']} PM") - 10_800
    post_at = Time.new(gametime.year, gametime.month, gametime.day, 6, 0, 0)

    next if post_at < Time.now

    @attempts += 1

    begin
      insert_game game['gameday'], post_at, gametime, game_title(game)
    rescue PG::UniqueViolation
      @failures += 1
    end
  end
end

def insert_game(gid, post_at, gametime, title)
  @conn.exec_params(
    'INSERT INTO gamechats (
      gid, post_at, starts_at, status, created_at, updated_at, subreddit_id,
      title)
    VALUES
    ($1, $2, $3, \'Future\', $4, $5, 15, $6)',
    [
      gid,
      post_at.strftime('%Y-%m-%d %H:%M:%S'),
      gametime.strftime('%Y-%m-%d %H:%M:%S'),
      @right_now,
      @right_now,
      title
    ]
  )
end

load_schedule

puts "Added #{@attempts - @failures} of #{@attempts}"
