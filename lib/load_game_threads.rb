# frozen_string_literal: true

require_relative 'default_bot'

class GameThreadLoader
  INSERT_GAME_THREAD = <<~SQL
    INSERT INTO game_threads (post_at, starts_at, subreddit_id, game_pk, status)
    VALUES ($1, $2, $3, $4, 'Future')
  SQL

  UPDATE_GAME_THREAD = <<~SQL
    UPDATE game_threads
    SET post_at = $1, starts_at = $2, updated_at = $3
    WHERE subreddit_id = $4 AND game_pk = $5 AND (
      starts_at != $2 OR post_at != $1
    ) AND date_trunc('day', starts_at) = date_trunc('day', $2)
  SQL

  ENABLED_SUBREDDITS = <<~SQL
    SELECT id, name, team_id, options#>>'{game_threads,post_at}' AS post_at
    FROM subreddits
    WHERE team_id IS NOT NULL
    AND (options#>>'{game_threads,enabled}')::boolean IS TRUE
  SQL

  def initialize
    @created = @updated = 0

    @bot = DefaultBot.create(
      purpose: 'Game Thread Loader',
      account: 'BaseballBot'
    )

    @utc_offset = Time.now.utc_offset
  end

  def run
    calculate_dates

    load_game_threads

    puts "Added #{@created} / Updated #{@updated}"
  end

  protected

  def calculate_dates
    if ARGV.count > 2
      raise 'Please pass 2 arguments: ruby load_schedule.rb ' \
            '[6/2015 [mariners,dodgers]]'
    end

    @date = if ARGV[0] =~ %r{\A(\d{1,2})/(\d{4})\z}
              Date.new(Regexp.last_match[2].to_i, Regexp.last_match[1].to_i, 1)
            else
              Date.today
            end

    @names = (ARGV[1] || '').split(%r{[+/,]}).map(&:downcase)
  end

  def load_game_threads
    @bot.db.exec(ENABLED_SUBREDDITS).each do |row|
      next unless @names.empty? || @names.include?(row['name'].downcase)

      post_at = Baseballbot::Utility.adjust_time_proc row['post_at']

      load_schedule row['id'], row['team_id'], post_at
    end
  end

  def load_schedule(subreddit_id, team_id, post_at)
    data = @bot.api.schedule(
      startDate: @date.strftime('%F'),
      endDate: (Date.new(@date.year, @date.month + 1, 1) - 1).strftime('%F'),
      teamId: team_id,
      eventTypes: 'primary',
      scheduleTypes: 'games,events,xref'
    )

    process_games data.dig('dates'), subreddit_id, post_at
  end

  def process_games(dates, subreddit_id, adjusted_time)
    dates.each do |date|
      date['games'].each do |game|
        next if game.dig('status', 'startTimeTBD')

        starts_at = Time.parse(game['gameDate']) + @utc_offset

        post_at = adjusted_time.call(starts_at)

        next if post_at < Time.now

        insert_game subreddit_id, game, post_at, starts_at
      end
    end
  end

  def insert_game(subreddit_id, game, post_at, starts_at)
    data = row_data(game, starts_at, post_at, subreddit_id)

    @bot.db.exec_params(
      INSERT_GAME_THREAD,
      data.values_at(:post_at, :starts_at, :subreddit_id, :game_pk)
    )

    @created += 1
  rescue PG::UniqueViolation
    update_game(data)
  end

  def row_data(game, starts_at, post_at, subreddit_id)
    {
      post_at: post_at.strftime('%F %T'),
      starts_at: starts_at.strftime('%F %T'),
      updated_at: Time.now.strftime('%F %T'),
      subreddit_id: subreddit_id,
      game_pk: game['gamePk'].to_i
    }
  end

  def update_game(data)
    result = @bot.db.exec_params(
      UPDATE_GAME_THREAD,
      data.values_at(:post_at, :starts_at, :updated_at, :subreddit_id, :game_pk)
    )

    @updated += result.cmd_tuples
  end
end

GameThreadLoader.new.run
