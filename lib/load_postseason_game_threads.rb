# frozen_string_literal: true

require_relative 'baseballbot'

class PostseasonGameLoader
  R_BASEBALL = 15

  def initialize
    @attempts = 0
    @failures = 0

    @api = MLBStatsAPI::Client.new
  end

  def conn
    @conn ||= PG::Connection.new(
      user: ENV['BASEBALLBOT_PG_USERNAME'],
      dbname: ENV['BASEBALLBOT_PG_DATABASE'],
      password: ENV['BASEBALLBOT_PG_PASSWORD']
    )
  end

  def run
    load_schedule

    puts "Added #{@attempts - @failures} of #{@attempts}"
  end

  def load_schedule
    data = @api.schedule(:postseason, hydrate: 'team,metadata,seriesStatus')

    data['dates'].each do |date|
      date['games'].each { |game| process_game(game) }
    end
  end

  def process_game(game)
    return unless add_game_to_schedule?(game)

    starts_at = Time.parse(game['gameDate']) - (7 * 3600)

    return if starts_at < Time.now

    insert_game game, starts_at, starts_at - 3600, title(game), R_BASEBALL

    insert_team_game game, starts_at
  end

  def team_subreddits
    @team_subreddits ||= team_subreddits_data.group_by { |row| row['team_id'] }
  end

  def team_subreddits_data
    conn.exec(<<~SQL)
      SELECT id, team_id, options#>>'{game_threads,post_at}' AS post_at,
        COALESCE(
          options#>>'{game_threads,title,postseason}',
          options#>>'{game_threads,title,default}'
        ) AS title
      FROM subreddits
      WHERE (options#>>'{game_threads,enabled}')::boolean IS TRUE
        AND team_id IS NOT NULL
    SQL
  end

  def insert_team_game(game, starts_at)
    %w[away home].each do |flag|
      subreddits = team_subreddits[game.dig('teams', flag, 'team', 'id').to_s]

      next unless subreddits

      subreddits.each do |row|
        post_at = Baseballbot.adjust_time_proc(row['post_at']).call starts_at

        insert_game game, starts_at, post_at, row['title'], row['id']
      end
    end
  end

  def add_game_to_schedule?(game)
    return false if game.dig('status', 'startTimeTBD')

    # If the team is undetermined, their division will be blank
    return false unless game.dig('teams', 'away', 'team', 'division')
    return false unless game.dig('teams', 'home', 'team', 'division')

    true
  end

  def insert_game(game, starts_at, post_at, title, subreddit_id)
    @attempts += 1

    data = row_data(game, starts_at, post_at, title, subreddit_id)

    conn.exec_params(
      "INSERT INTO game_threads (#{data.keys.join(', ')})" \
      "VALUES (#{(1..data.size).map { |n| "$#{n}" }.join(', ')})",
      data.values
    )
  rescue PG::UniqueViolation
    @failures += 1
  end

  def row_data(game, starts_at, post_at, title, subreddit_id)
    {
      game_pk: game['gamePk'],
      post_at: post_at.strftime('%Y-%m-%d %H:%M:%S'),
      starts_at: starts_at.strftime('%Y-%m-%d %H:%M:%S'),
      subreddit_id: subreddit_id,
      title: title
    }
  end

  def title(game)
    return baseball_subreddit_titles['wildcard'] if game['gameType'] == 'F'

    baseball_subreddit_titles['postseason']
  end

  def baseball_subreddit_titles
    @baseball_subreddit_titles ||= conn.exec(<<~SQL).first
      SELECT
        options#>>'{game_threads,title,postseason}' AS postseason,
        options#>>'{game_threads,title,wildcard}' AS wildcard
      FROM subreddits
      WHERE id = #{R_BASEBALL}
    SQL
  end
end

# PostseasonGameLoader.new.run
