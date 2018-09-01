# frozen_string_literal: true

class Baseballbot
  module GameThreads
    UNPOSTED_GAME_THREADS_QUERY = <<~SQL
      SELECT game_threads.id, game_pk, subreddits.name, title
      FROM game_threads
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status IN ('Pregame', 'Future')
        AND post_at <= NOW()
        AND (options#>>'{game_threads,enabled}')::boolean IS TRUE
      ORDER BY post_at ASC, game_pk ASC
    SQL

    ACTIVE_GAME_THREADS_QUERY = <<~SQL
      SELECT game_threads.id, game_pk, subreddits.name, post_id
      FROM game_threads
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status = 'Posted'
        AND starts_at <= NOW()
        AND (options#>>'{game_threads,enabled}')::boolean IS TRUE
      ORDER BY post_id ASC
    SQL

    def post_game_threads!(names: [])
      names = names.map(&:downcase)

      unposted_game_threads.each do |row|
        next unless names.empty? || names.include?(row['name'].downcase)

        post_game_thread!(
          id: row['id'],
          name: row['name'],
          game_pk: row['game_pk'],
          title: row['title']
        )
      end
    end

    def post_game_thread!(id:, name:, game_pk:, title:)
      Baseballbot::Posts::GameThread.new(
        id: id,
        game_pk: game_pk,
        title: title,
        subreddit: name_to_subreddit(name)
      ).create!
    rescue Redd::ServerError, ::OpenURI::HTTPError
      # Waiting an extra few minutes won't kill anyone.
      nil
    end

    def update_game_threads!(names: [])
      names = names.map(&:downcase)

      active_game_threads.each do |row|
        next unless names.empty? || names.include?(row['name'].downcase)

        update_game_thread!(
          name: row['name'],
          id: row['id'],
          game_pk: row['game_pk'],
          post_id: row['post_id']
        )
      end
    end

    # Update a game thread - also starts the "game over" process if necessary
    #
    # @param name [String] The name of the subreddit to post in
    # @param id [String] The baseballbot id of the game thread
    # @param game_pk [Integer] The mlb id of the game
    # @param post_id [String] The reddit id of the post to update
    def update_game_thread!(name:, id:, game_pk:, post_id:)
      Baseballbot::Posts::GameThread.new(
        id: id,
        game_pk: game_pk,
        post_id: post_id,
        subreddit: name_to_subreddit(name)
      ).update!
    rescue Redd::InvalidAccess
      invalid_access(post_id)
    rescue Redd::ServerError, ::OpenURI::HTTPError
      # Waiting an extra few minutes won't kill anyone.
      nil
    end

    def invalid_access(post_id)
      puts "Could not update #{post_id} due to invalid credentials:"
      puts "\tExpires: #{current_account.access.expires_at.strftime '%F %T'}"
      puts "\tCurrent: #{Time.now.strftime '%F %T'}"

      refresh_access!

      puts "\tExpires: #{current_account.access.expires_at.strftime '%F %T'}"
    end

    def active_game_threads
      @active_game_threads ||= @db.exec(ACTIVE_GAME_THREADS_QUERY)
    end

    def unposted_game_threads
      @unposted_game_threads ||= @db.exec(UNPOSTED_GAME_THREADS_QUERY)
    end
  end
end
