# frozen_string_literal: true

class Baseballbot
  module OffDay
    UNPOSTED_OFF_DAY_QUERY = <<~SQL
      SELECT name
      FROM subreddits
      WHERE (options#>>'{off_day,enabled}')::boolean IS TRUE
      AND (
        (options#>>'{off_day,last_run_at}') IS NULL OR
        DATE((options#>>'{off_day,last_run_at}')) < DATE(NOW())
      )
      AND (
        (DATE(NOW()) + (options#>>'{off_day,post_at}')::interval) <
          NOW() AT TIME ZONE (options->>'timezone')
      )
      ORDER BY name ASC
    SQL

    def post_off_day_threads!(names: [])
      names = names.map(&:downcase)

      db.exec(UNPOSTED_OFF_DAY_QUERY).each do |row|
        next unless names.empty? || names.include?(row['name'].downcase)

        post_off_day_thread! name: row['name']
      end
    end

    def post_off_day_thread!(name:)
      Honeybadger.context(subreddit: name)

      subreddit = name_to_subreddit(name)

      off_day_check_was_run!(subreddit)

      return unless subreddit.post_off_day_thread?

      Baseballbot::Posts::OffDay.new(subreddit: subreddit).create!
    rescue => e
      Honeybadger.notify(e)
    end

    def off_day_check_was_run!(subreddit)
      subreddit.options['off_day']['last_run_at'] = Time.now.strftime('%F %T')

      db.exec_params(
        'UPDATE subreddits SET options = $1 WHERE id = $2',
        [JSON.dump(subreddit.options), subreddit.id]
      )
    end
  end
end
