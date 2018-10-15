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
      unposted_game_threads(names).each do |row|
        build_game_thread(row).create!
      rescue Redd::InvalidAccess
        refresh_access!
      rescue => ex
        Honeybadger.notify(ex)
      end
    end

    def update_game_threads!(names: [])
      game_threads_to_update(names).each do |row|
        build_game_thread(row).update!
      rescue Redd::InvalidAccess
        refresh_access!
      rescue => ex
        Honeybadger.notify(ex)
      end
    end

    def build_game_thread(row)
      Baseballbot::Posts::GameThread.new(
        id: row['id'],
        game_pk: row['game_pk'],
        post_id: row['post_id'],
        title: data['title'],
        subreddit: name_to_subreddit(row['name']),
        type: row['type']
      )
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

    def unposted_game_threads(names)
      names = names.map(&:downcase)

      next unless names.empty? || names.include?(row['name'].downcase)

      @unposted_game_threads ||= @db.exec(UNPOSTED_GAME_THREADS_QUERY)
    end

    def posted_game_threads
      @posted_game_threads ||= @db.exec(POSTED_GAME_THREADS_QUERY)
    end
  end
end
