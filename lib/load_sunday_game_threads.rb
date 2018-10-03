# frozen_string_literal: true

# This file really needs to be cleaned up, as does the entire /lib/ directory.

require 'pg'
require 'json'
require 'open-uri'
require 'chronic'
require 'tzinfo'

class SundayGameThreadLoader
  R_BASEBALL_ID = 15
  URL = 'http://gdx.mlb.com/components/game/mlb/year_%Y/month_%m/day_%d/' \
        'miniscoreboard.json'

  def initialize
    @attempts = 0
    @failures = 0

    @timestamp = Time.now.strftime '%Y-%m-%d %H:%M:%S'
  end

  def run
    (0..4).each { |n| load_espn_game Chronic.parse("#{n} weeks from Sunday") }

    puts "Added #{@attempts - @failures} of #{@attempts}"
  end

  protected

  def conn
    @conn ||= PG::Connection.new(
      user: ENV['BASEBALLBOT_PG_USERNAME'],
      dbname: ENV['BASEBALLBOT_PG_DATABASE'],
      password: ENV['BASEBALLBOT_PG_PASSWORD']
    )
  end

  def load_espn_game(date)
    data = JSON.parse URI.parse(date.strftime(URL)).open.read

    data.dig('data', 'games', 'game').each do |game|
      # Game time is not yet set or something is TBD
      next unless game['game_type'] == 'R' && game['tv_station'] == 'ESPN'

      zulu = Time.parse game.dig('game_media', 'media', 'start')

      offset = TZInfo::Timezone.get('America/Los_Angeles')
        .period_for_utc(zulu)
        .utc_total_offset

      gametime = zulu + offset

      next if gametime < Time.now

      insert_game game['game_pk'], gametime
    end
  end

  def insert_game(game_pk, starts_at)
    @attempts += 1

    data = game_data(game_pk, starts_at)

    conn.exec_params(
      "INSERT INTO game_threads (#{data.keys.join(', ')})" \
      "VALUES (#{(1..data.size).map { |n| "$#{n}" }.join(', ')})",
      data.values
    )

    puts "+ #{game_pk}"
  rescue PG::UniqueViolation
    @failures += 1

    puts "- #{game_pk}"
  end

  def game_data(game_pk, starts_at)
    {
      game_pk: game_pk,
      post_at: (starts_at - 3600).strftime('%F %T'),
      starts_at: starts_at.strftime('%F %T'),
      status: 'Future',
      created_at: @timestamp,
      updated_at: @timestamp,
      subreddit_id: R_BASEBALL_ID
    }
  end
end

SundayGameThreadLoader.new.run
