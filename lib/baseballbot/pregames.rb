# frozen_string_literal: true

class Baseballbot
  module Pregames
    UNPOSTED_PREGAMES_QUERY = <<~SQL
      SELECT gamechats.id, game_pk, subreddits.name
      FROM gamechats
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status = 'Future'
        AND (options#>>'{pregame,enabled}')::boolean IS TRUE
        AND (
          CASE WHEN substr(options#>>'{pregame,post_at}', 1, 1) = '-'
            THEN (starts_at::timestamp + (
              CONCAT(options#>>'{pregame,post_at}', ' hours')
            )::interval) < NOW()
            ELSE (
              DATE(starts_at) + (options#>>'{pregame,post_at}')::interval
            ) < NOW() AT TIME ZONE (options->>'timezone')
          END)
      ORDER BY post_at ASC, game_pk ASC
    SQL

    def post_pregames!(names: [])
      names = names.map(&:downcase)

      @db.exec(UNPOSTED_PREGAMES_QUERY).each do |row|
        next unless names.empty? || names.include?(row['name'].downcase)

        post_pregame!(
          id: row['id'],
          name: row['name'],
          game_pk: row['game_pk']
        )
      end
    end

    def post_pregame!(id:, name:, game_pk:)
      name_to_subreddit(name).post_pregame(id: id, game_pk: game_pk)
    rescue Redd::ServerError, ::OpenURI::HTTPError
      # Waiting an extra 2 minutes won't kill anyone.
      nil
    rescue => ex
      Honeybadger.notify(ex, context: { name: name })
    end
  end
end
