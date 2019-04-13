# frozen_string_literal: true

class Baseballbot
  module Pregames
    UNPOSTED_PREGAMES_QUERY = <<~SQL
      SELECT game_threads.id, game_pk, subreddits.name
      FROM game_threads
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

    def post_pregame_threads!(names: [])
      names = names.map(&:downcase)

      db.exec(UNPOSTED_PREGAMES_QUERY).each do |row|
        next unless names.empty? || names.include?(row['name'].downcase)

        post_pregame_thread!(
          id: row['id'],
          name: row['name'],
          game_pk: row['game_pk']
        )
      end
    end

    def post_pregame_thread!(id:, name:, game_pk:)
      Honeybadger.context(id: id, subreddit: name, game_pk: game_pk)

      Baseballbot::Posts::Pregame.new(
        id: id,
        game_pk: game_pk,
        subreddit: name_to_subreddit(name)
      ).create!
    rescue => e
      Honeybadger.notify(e)
    end
  end
end
