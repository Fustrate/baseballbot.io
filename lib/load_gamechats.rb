# frozen_string_literal: true

require 'pg'
require 'json'
require 'open-uri'
require 'chronic'
require 'mlb_gameday'

class GamechatLoader
  URL = 'https://statsapi.mlb.com/api/v1/schedule?sportId=1&season=%<year>d&' \
        'startDate=%<start_date>s&endDate=%<end_date>s&teamId=%<team_id>d&' \
        'eventTypes=primary&scheduleTypes=games,events,xref'

  def initialize
    @attempts = 0
    @failures = 0

    @right_now = Time.now.strftime('%Y-%m-%d %H:%M:%S')

    @api = MLBGameday::API.new
  end

  def run
    calculate_dates

    load_gamechats

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
    format(
      URL,
      start_date: @start_date.strftime('%Y-%m-%d'),
      end_date: @end_date.strftime('%Y-%m-%d'),
      team_id: team_id,
      year: @start_date.year
    )
  end

  def load_schedule(subreddit_id, code, post_at)
    team = @api.team code

    unless team
      puts "Invalid team code: #{code}"
      return
    end

    data = JSON.parse open(schedule_url(team.id)).read

    process_games(data.dig('dates'), subreddit_id, adjust_time_proc(post_at))
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
      "INSERT INTO gamechats (#{data.keys.join(', ')})" \
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

  def load_gamechats
    enabled_subreddits.each do |row|
      next unless @names.empty? || @names.include?(row['name'].downcase)

      load_schedule(
        row['id'],
        row['team_code'],
        row['post_at']
      )
    end
  end

  def enabled_subreddits
    conn.exec(
      "SELECT id, name, team_code, options#>>'{gamechats,post_at}' AS post_at
      FROM subreddits
      WHERE (options#>>'{gamechats,enabled}')::boolean IS TRUE"
    )
  end

  def adjust_time_proc(post_at)
    if post_at =~ /\A\-?\d{1,2}\z/
      ->(time) { time + Regexp.last_match[0].to_i * 3600 }
    elsif post_at =~ /(1[012]|\d)(:\d\d|) ?(am|pm)/i
      lambda do |time|
        hours = Regexp.last_match[1].to_i
        hours += 12 if hours != 12 && Regexp.last_match[3].casecmp('pm').zero?
        minutes = (Regexp.last_match[1] || ':00')[1..2].to_i

        Time.new(time.year, time.month, time.day, hours, minutes, 0)
      end
    else
      # Default to 3 hours before game time
      ->(time) { time - 3 * 3600 }
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

GamechatLoader.new.run
