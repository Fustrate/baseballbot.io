# frozen_string_literal: true

require 'pg'
require 'json'
require 'open-uri'
require 'chronic'

class GameThreadLoader
  def initialize
    @attempts = 0
    @failures = 0

    @right_now = Time.now.strftime('%Y-%m-%d %H:%M:%S')
  end

  def run
    calculate_dates

    load_game_threads

    puts "Added #{@attempts - @failures} of #{@attempts}"
  end

  protected

  def conn
    @conn ||= PG::Connection.new(
      user: ENV['PG_USERNAME'],
      dbname: ENV['PG_DATABASE'],
      password: ENV['PG_PASSWORD']
    )
  end

  def schedule_url(team_id)
    @bot.api.schedule(
      sportId: 1,
      season: @start_date.year,
      startDate: @start_date.strftime('%Y-%m-%d'),
      endDate: @end_date.strftime('%Y-%m-%d'),
      teamId: team_id,
      eventTypes: 'primary',
      scheduleTypes: 'games,events,xref'
    )
  end

  def load_schedule(subreddit_id, team_id, post_at)
    data = JSON.parse URI.parse(schedule_url(team_id)).open.read

    process_games data.dig('dates'), subreddit_id, adjust_time_proc(post_at)
  end

  def process_games(dates, subreddit_id, adjusted_time)
    # If there's only one game in this month (like 10/2017) then the API only
    # returns a hash *not* wrapped in an array.
    dates.each do |date|
      date['games'].each do |game|
        gametime = Chronic.parse(game['gameDate']) - (7 * 3_600)

        # next if game['game_time_et'][11..15] == '03:33'

        post_at = adjusted_time.call(gametime)

        next if post_at < Time.now

        insert_game subreddit_id, game, post_at, gametime
      end
    end
  end

  def insert_game(subreddit_id, game, post_at, gametime)
    @attempts += 1

    data = row_data(game, gametime, post_at, subreddit_id)

    conn.exec_params(
      "INSERT INTO game_threads (#{data.keys.join(', ')})" \
      "VALUES (#{(1..data.size).map { |n| "$#{n}" }.join(', ')})",
      data.values
    )
  rescue PG::UniqueViolation
    @failures += 1
  end

  def row_data(game, gametime, post_at, subreddit_id)
    game_pk = game['gamePk'].to_i

    {
      post_at: post_at.strftime('%Y-%m-%d %H:%M:%S'),
      starts_at: gametime.strftime('%Y-%m-%d %H:%M:%S'),
      status: 'Future',
      created_at: @right_now,
      updated_at: @right_now,
      subreddit_id: subreddit_id,
      game_pk: game_pk
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

      load_schedule row['id'], row['team_id'], row['post_at']
    end
  end

  def enabled_subreddits
    conn.exec(
      "SELECT id, name, team_id, options#>>'{game_threads,post_at}' AS post_at
      FROM subreddits
      WHERE team_id IS NOT NULL
      AND (options#>>'{game_threads,enabled}')::boolean IS TRUE"
    )
  end

  def adjust_time_proc(post_at)
    if post_at =~ /\A\-?\d{1,2}\z/
      ->(time) { time - Regexp.last_match[0].to_i.abs * 3600 }
    elsif post_at =~ /(1[012]|\d)(:\d\d|) ?(am|pm)/i
      constant_time(Regexp.last_match)
    else
      # Default to 3 hours before game time
      ->(time) { time - 3 * 3600 }
    end
  end

  def constant_time(match_data)
    lambda do |time|
      hours = match_data[1].to_i
      hours += 12 if hours != 12 && match_data[3].casecmp('pm').zero?
      minutes = (match_data[2] || ':00')[1..2].to_i

      Time.new(time.year, time.month, time.day, hours, minutes, 0)
    end
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
