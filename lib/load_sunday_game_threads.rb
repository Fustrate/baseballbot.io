# frozen_string_literal: true

require_relative 'baseballbot'

# Add the ESPN game of the week to /r/baseball's schedule
class SundayGameThreadLoader
  R_BASEBALL_ID = 15

  def initialize
    @attempts = @failures = 0

    @bot = Baseballbot.new

    @utc_offset = Time.now.utc_offset
  end

  def run
    (0..4).each { |n| load_espn_game Chronic.parse("#{n} weeks from Sunday") }

    puts "Added #{@attempts - @failures} of #{@attempts}"
  end

  protected

  def load_espn_game(date)
    sunday_games(date).each do |game|
      # Game time is not yet set or something is TBD
      next unless game['gameType'] == 'R' && espn_game?(game)

      starts_at = Time.parse(game['gameDate']) + @utc_offset

      next if starts_at < Time.now

      insert_game game, starts_at
    end
  end

  def sunday_games(date)
    @bot.api.schedule(
      sportId: 1,
      date: date.strftime('%m/%d/%Y'),
      hydrate: 'game(content(media(epg)))'
    ).dig('dates', 0, 'games')
  end

  def espn_game?(game)
    game.dig('content', 'media', 'epg')
      .find { |content| content['title'] == 'MLBTV' }
      &.dig('items')
      &.any? { |station| station['callLetters'] == 'ESPN' }
  end

  def insert_game(game, starts_at)
    @attempts += 1

    data = game_data(game, starts_at)

    @bot.db.exec_params(
      "INSERT INTO game_threads (#{data.keys.join(', ')})" \
      "VALUES (#{(1..data.size).map { |n| "$#{n}" }.join(', ')})",
      data.values
    )

    puts "+ #{game['gamePk']}"
  rescue PG::UniqueViolation
    failed_to_insert(game)
  end

  def game_data(game, starts_at)
    {
      game_pk: game['gamePk'],
      post_at: (starts_at - 3600).strftime('%F %T'),
      starts_at: starts_at.strftime('%F %T'),
      status: 'Future',
      subreddit_id: R_BASEBALL_ID
    }
  end

  def failed_to_insert(game)
    @failures += 1

    puts "- #{game['gamePk']}"
  end
end

SundayGameThreadLoader.new.run
