# frozen_string_literal: true

require 'pg'
require 'json'
require 'open-uri'
require 'chronic'

class PostseasonGameLoader
  SUBREDDIT_ID = 15
  URL = 'http://m.mlb.com/gdcross/components/game/mlb/year_%Y/' \
        'postseason_scoreboard.json'

  def initialize
    @right_now = Time.now.strftime '%Y-%m-%d %H:%M:%S'

    @attempts = 0
    @failures = 0
  end

  def conn
    @conn ||= PG::Connection.new(
      user: ENV['PG_USERNAME'],
      dbname: ENV['PG_DATABASE'],
      password: ENV['PG_PASSWORD']
    )
  end

  def run
    load_schedule

    puts "Added #{@attempts - @failures} of #{@attempts}"
  end

  def load_schedule
    data = JSON.parse URI.parse(Date.today.strftime(URL)).open.read

    data['games'].each do |game|
      # Game time is not yet set or something is TBD
      next if game['time'] == '3:33' || game['tbd_flag'] == 'Y'
      # If the team is undetermined, their division will be blank
      next if game['home_division'] == '' || game['away_division'] == ''

      gametime = Chronic.parse(
        "#{game['original_date']} #{game['first_pitch_et']} PM"
      ) - 10_800

      next if gametime < Time.now

      insert_game game['game_pk'], gametime, game_title(game)
    end
  end

  def insert_game(game_pk, gametime, title)
    @attempts += 1

    data = row_data(game_pk, gametime, title)

    conn.exec_params(
      "INSERT INTO game_threads (#{data.keys.join(', ')})" \
      "VALUES (#{(1..data.size).map { |n| "$#{n}" }.join(', ')})",
      data.values
    )
  rescue PG::UniqueViolation
    @failures += 1
  end

  def row_data(game_pk, gametime, title)
    {
      game_pk: game_pk,
      post_at: (gametime - 3600).strftime('%Y-%m-%d %H:%M:%S'),
      starts_at: gametime.strftime('%Y-%m-%d %H:%M:%S'),
      status: 'Future',
      created_at: @right_now,
      updated_at: @right_now,
      subreddit_id: SUBREDDIT_ID,
      title: title
    }
  end

  def game_title(row)
    if row['game_type'] == 'F'
      # Wild Card game
      return "Game Thread: #{row['series']} ⚾ #{row['away_team_name']} @ " \
             "#{row['home_team_name']} - #{row['first_pitch_et']} PM ET"
    end

    'Game Thread: %<series_game>s ⚾ %<away_name>s (%<away_record>s) @ ' \
    '%<home_name>s (%<home_record>s) - %<start_time_et>s PM ET'
  end
end

PostseasonGameLoader.new.run
