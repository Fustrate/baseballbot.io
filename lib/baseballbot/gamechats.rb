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

      unposted_gamechats.each do |row|
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
      Baseballbot::Posts::GameChat.new(
        id: id,
        game_pk: game_pk,
        title: title,
        subreddit: name_to_subreddit(name)
      ).create!
    rescue Redd::ServerError, ::OpenURI::HTTPError
      # Waiting an extra few minutes won't kill anyone.
      nil
    end

    def update_gamechats!(names: [])
      names = names.map(&:downcase)

      active_gamechats.each do |row|
        next unless names.empty? || names.include?(row['name'].downcase)

        update_gamechat!(
          name: row['name'],
          id: row['id'],
          game_pk: row['game_pk'],
          post_id: row['post_id']
        )
      end
    end

    # Update a gamechat - also starts the "game over" process if necessary
    #
    # @param name [String] The name of the subreddit to post in
    # @param id [String] The baseballbot id of the gamechat
    # @param game_pk [Integer] The mlb id of the game
    # @param post_id [String] The reddit id of the post to update
    def update_gamechat!(name:, id:, game_pk:, post_id:)
      Baseballbot::Posts::GameChat.new(
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

    def active_gamechats
      @active_gamechats ||= @db.exec(ACTIVE_GAMECHATS_QUERY)
    end

    def unposted_gamechats
      @unposted_gamechats ||= @db.exec(UNPOSTED_GAMECHATS_QUERY)
    end
  end
end
