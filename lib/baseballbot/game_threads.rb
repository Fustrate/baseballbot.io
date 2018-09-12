# frozen_string_literal: true

class Baseballbot
  module GameThreads
    UNPOSTED_GAME_THREADS_QUERY = <<~SQL
      SELECT game_threads.id, game_pk, subreddits.name, title, type
      FROM game_threads
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status IN ('Pregame', 'Future')
        AND post_at <= NOW()
        AND (options#>>'{game_threads,enabled}')::boolean IS TRUE
      ORDER BY post_at ASC, game_pk ASC
    SQL

    ACTIVE_GAME_THREADS_QUERY = <<~SQL
      SELECT game_threads.id, game_pk, subreddits.name, post_id, type
      FROM game_threads
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status = 'Posted'
        AND starts_at <= NOW()
      ORDER BY post_id ASC
    SQL

    POSTED_GAME_THREADS_QUERY = <<~SQL
      SELECT game_threads.id, game_pk, subreddits.name, post_id, type
      FROM game_threads
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status = 'Posted'
      ORDER BY post_id ASC
    SQL

    def post_game_threads!(names: [])
      names = names.map(&:downcase)

      unposted_game_threads.each do |row|
        next unless names.empty? || names.include?(row['name'].downcase)

        post_game_thread! row
      end
    end

    def post_game_thread!(data)
      Baseballbot::Posts::GameThread.new(
        id: data['id'],
        game_pk: data['game_pk'],
        title: data['title'],
        subreddit: name_to_subreddit(data['name']),
        type: data['type']
      ).create!
    rescue => ex
      Honeybadger.notify(ex, context: { data: data })
    end

    def update_game_threads!(names: [])
      game_threads_to_update(names).each do |row|
        update_game_thread! row
      end
    end

    # Update a game thread - also starts the "game over" process if necessary
    #
    # @param name [String] The name of the subreddit to post in
    # @param id [String] The baseballbot id of the game thread
    # @param game_pk [Integer] The mlb id of the game
    # @param post_id [String] The reddit id of the post to update
    def update_game_thread!(data)
      Baseballbot::Posts::GameThread.new(
        id: data['id'],
        game_pk: data['game_pk'],
        post_id: data['post_id'],
        subreddit: name_to_subreddit(data['name']),
        type: data['type']
      ).update!
    rescue Redd::InvalidAccess
      refresh_access!
    rescue => ex
      Honeybadger.notify(ex, context: { data: data })
    end

    # Every 10 minutes, update every game thread no matter what.
    def game_threads_to_update(names)
      names = names.map(&:downcase)

      return posted_game_threads if names.include?('posted')

      active_game_threads.select do |row|
        names.empty? || names.include?(row['name'].downcase)
      end
    end

    def active_game_threads
      @active_game_threads ||= @db.exec(ACTIVE_GAME_THREADS_QUERY)
    end

    def unposted_game_threads
      @unposted_game_threads ||= @db.exec(UNPOSTED_GAME_THREADS_QUERY)
    end

    def posted_game_threads
      @posted_game_threads ||= @db.exec(POSTED_GAME_THREADS_QUERY)
    end
  end
end
