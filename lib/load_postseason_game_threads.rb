# frozen_string_literal: true

require 'pg'
require 'json'
require 'open-uri'
require 'chronic'

class PostseasonGameLoader
  SUBREDDIT_ID = 15
  URL = 'https://statsapi.mlb.com/api/v1/schedule/postseason?season=%Y'

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

    data['dates'].each do |date|
      date['games'].each do |game|
        next unless add_game_to_schedule?

        gametime = Time.parse(game['gameDate']) - (7 * 3600)

        next if gametime < Time.now

        insert_game game['gamePk'], gametime, game_title(game)
      end
    end
  end

  def add_game_to_schedule?
    return false if game.dig('game', 'status', 'startTimeTBD')

    # If the team is undetermined, their division will be blank
    return false unless game.dig('game', 'teams', 'away', 'team', 'division')
    return false unless game.dig('game', 'teams', 'home', 'team', 'division')

    true
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
      return 'Game Thread: %<series_game>s ⚾ %<away_name>s @ ' \
             '%<home_name>s - %<start_time_et>s PM ET'
    end

    'Game Thread: %<series_game>s ⚾ %<away_name>s (%<away_wins>d) @ ' \
    '%<home_name>s (%<home_wins>d) - %<start_time_et>s PM ET'
  end
end

PostseasonGameLoader.new.run
