# frozen_string_literal: true

require 'pg'
require 'chronic'
require 'mlb_stats_api'

class GameThreadLoader
  INSERT_GAME_THREAD = <<~SQL
    INSERT INTO game_threads (
      post_at, starts_at, subreddit_id, game_pk, status
    ) VALUES ($1, $2, $3, $4, 'Future')
  SQL

  UPDATE_GAME_THREAD = <<~SQL
    UPDATE game_threads
    SET post_at = $1, starts_at = $2, updated_at = $3
    WHERE subreddit_id = $4 AND game_pk = $5 AND (
      starts_at != $2 OR post_at != $1
    ) AND date_trunc('day', starts_at) = date_trunc('day', $2)
  SQL

  def initialize
    @created = 0
    @updated = 0

    @right_now = Time.now.strftime('%Y-%m-%d %H:%M:%S')

    @api = MLBStatsAPI::Client.new
  end

  def run
    calculate_dates

    load_game_threads

    puts "Added #{@created} / Updated #{@updated}"
  end

  protected

  def conn
    @conn ||= PG::Connection.new(
      user: ENV['ROBOSCORE_PG_USERNAME'],
      dbname: ENV['ROBOSCORE_PG_DATABASE'],
      password: ENV['ROBOSCORE_PG_PASSWORD']
    )
  end

  def load_schedule(subreddit_id, team_id, post_at)
    data = @api.schedule(
      startDate: @start_date.strftime('%Y-%m-%d'),
      endDate: @end_date.strftime('%Y-%m-%d'),
      teamId: team_id,
      eventTypes: 'primary',
      scheduleTypes: 'games,events,xref'
    )

    process_games data.dig('dates'), subreddit_id, post_at
  end

  def process_games(dates, subreddit_id, adjusted_time)
    dates.each do |date|
      date['games'].each do |game|
        gametime = Time.parse(game['gameDate']) - (7 * 3_600)

        # next if game['game_time_et'][11..15] == '03:33'

        post_at = adjusted_time.call(gametime)

        next if post_at < Time.now

        insert_game subreddit_id, game, post_at, gametime
      end
    end
  end

  def insert_game(subreddit_id, game, post_at, gametime)
    data = row_data(game, gametime, post_at, subreddit_id)

    conn.exec_params(
      INSERT_GAME_THREAD,
      data.values_at(:post_at, :starts_at, :subreddit_id, :game_pk)
    )

    @created += 1
  rescue PG::UniqueViolation
    update_game(data)
  end

  def update_game(data)
    result = conn.exec_params(
      UPDATE_GAME_THREAD,
      data.values_at(:post_at, :starts_at, :updated_at, :subreddit_id, :game_pk)
    )

    @updated += result.cmd_tuples
  end

  def row_data(game, gametime, post_at, subreddit_id)
    {
      post_at: post_at.strftime('%Y-%m-%d %H:%M:%S'),
      starts_at: gametime.strftime('%Y-%m-%d %H:%M:%S'),
      updated_at: @right_now,
      subreddit_id: subreddit_id,
      game_pk: game['gamePk'].to_i
    }
  end

  def calculate_dates
    if ARGV.count == 2
      two_parameters_passed
    elsif ARGV.count == 1
      single_parameter_passed
    else
      raise InvalidParametersError
    end

    @start_date = Chronic.parse "#{@month}/1/#{@year}"
    @end_date = Chronic.parse("#{@month.to_i + 1}/1/#{@year}") - 86_400
  end

  def single_parameter_passed
    if ARGV[0] =~ %r{(\d+)/(\d+)}
      _, @month, @year = Regexp.last_match.to_a
      @names = []
    else
      @month = Time.now.month
      @year = Time.now.year
      @names = ARGV[0].split(%r{[+/,]}).map(&:downcase)
    end
  end

  def two_parameters_passed
    @month, @year = ARGV[1].split(%r{[-/]}).map(&:to_i)
    @names = ARGV[0].split(%r{[+/,]}).map(&:downcase)
  end

  def load_game_threads
    enabled_subreddits.each do |row|
      next unless @names.empty? || @names.include?(row['name'].downcase)

      post_at = Baseballbot::Utility.adjust_time_proc row['post_at']

      load_schedule row['id'], row['team_id'], post_at
    end
  end

  def enabled_subreddits
    conn.exec(<<~SQL)
      SELECT id, name, team_id, options#>>'{game_threads,post_at}' AS post_at
      FROM subreddits
      WHERE team_id IS NOT NULL
      AND (options#>>'{game_threads,enabled}')::boolean IS TRUE
    SQL
  end

  class InvalidParametersError < RuntimeError
    DEFAULT_ERROR_MESSAGE = 'Please pass 2 arguments: ' \
                            'ruby load_schedule.rb mariners,dodgers 6/2015'

    def initialize(msg = DEFAULT_ERROR_MESSAGE)
      super
    end
  end
end

GameThreadLoader.new.run
