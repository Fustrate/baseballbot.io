# frozen_string_literal: true

class Baseballbot
  module Pregames
    UNPOSTED_PREGAMES = <<~SQL
      SELECT gamechats.id, gid, subreddits.name
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
      ORDER BY post_at ASC, gid ASC
    SQL

    def post_pregames!(names: [])
      names = names.map(&:downcase)

      @db.exec(Queries::UNPOSTED_PREGAMES).each do |row|
        next unless names.empty? || names.include?(row['name'].downcase)

        post_pregame! id: row['id'], team: row['name'], gid: row['gid']
      end
    end

    def post_pregame!(id:, team:, gid:)
      team_to_subreddit(team).post_pregame(id: id, gid: gid)
    rescue Redd::ServerError, ::OpenURI::HTTPError
      # Waiting an extra 2 minutes won't kill anyone.
      nil
    rescue => ex
      Honeybadger.notify(ex, context: { team: team })
    end
  end
end
