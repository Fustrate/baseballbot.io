# frozen_string_literal: true

class Baseballbot
  module Gamechats
    UNPOSTED_GAMECHATS_QUERY = <<~SQL
      SELECT gamechats.id, game_pk, subreddits.name, title
      FROM gamechats
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status IN ('Pregame', 'Future')
        AND post_at <= NOW()
        AND (options#>>'{gamechats,enabled}')::boolean IS TRUE
      ORDER BY post_at ASC, game_pk ASC
    SQL

    ACTIVE_GAMECHATS_QUERY = <<~SQL
      SELECT gamechats.id, game_pk, subreddits.name, post_id
      FROM gamechats
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status = 'Posted'
        AND starts_at <= NOW()
        AND (options#>>'{gamechats,enabled}')::boolean IS TRUE
      ORDER BY post_id ASC
    SQL

    def post_gamechats!(names: [])
      names = names.map(&:downcase)

      @db.exec(UNPOSTED_GAMECHATS_QUERY).each do |row|
        next unless names.empty? || names.include?(row['name'].downcase)

        post_gamechat!(
          id: row['id'],
          name: row['name'],
          game_pk: row['game_pk'],
          title: row['title']
        )
      end
    end

    def post_gamechat!(id:, name:, game_pk:, title:)
      name_to_subreddit(name).post_gamechat(
        id: id,
        game_pk: game_pk,
        title: title
      )
    rescue Redd::ServerError, ::OpenURI::HTTPError
      # Waiting an extra 2 minutes won't kill anyone.
      nil
    end

    def update_gamechats!(names: [])
      names = names.map(&:downcase)

      @db.exec(ACTIVE_GAMECHATS_QUERY).each do |row|
        next unless names.empty? || names.include?(row['name'].downcase)

        update_gamechat!(
          name: row['name'],
          id: row['id'],
          game_pk: row['game_pk'],
          post_id: row['post_id']
        )
      end
    end

    def update_gamechat!(name:, id:, game_pk:, post_id:)
      first_attempt ||= true

      name_to_subreddit(name)
        .update_gamechat(id: id, game_pk: game_pk, post_id: post_id)
    rescue Redd::InvalidAccess
      gamechat_update_failed(post_id)

      if first_attempt
        first_attempt = false
        retry
      end
    rescue Redd::ServerError, ::OpenURI::HTTPError
      # Waiting an extra 2 minutes won't kill anyone.
      nil
    end

    def gamechat_update_failed(post_id)
      puts "Could not update #{post_id} due to invalid credentials:"
      puts "\tExpires: #{current_account.access.expires_at.strftime '%F %T'}"
      puts "\tCurrent: #{Time.now.strftime '%F %T'}"

      refresh_access!

      puts "\tExpires: #{current_account.access.expires_at.strftime '%F %T'}"
    end
  end
end
