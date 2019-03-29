# frozen_string_literal: true

class Baseballbot
  module Sidebars
    SUBREDDITS_WITH_SIDEBARS_QUERY = <<~SQL
      SELECT name
      FROM subreddits
      WHERE (options#>>'{sidebar,enabled}')::boolean IS TRUE
      ORDER BY id ASC
    SQL

    def update_sidebars!(names: [])
      names = names.map(&:downcase)

      db.exec(SUBREDDITS_WITH_SIDEBARS_QUERY).each do |row|
        next unless names.empty? || names.include?(row['name'].downcase)

        update_sidebar! name_to_subreddit(subreddits[row['name']])
      end
    end

    def update_sidebar!(subreddit)
      settings = { description: subreddit.generate_sidebar }

      subreddit.modify_settings settings
    rescue => ex
      id = Honeybadger.notify(
        ex,
        context: (settings || {}).merge(name: subreddit.name)
      )

      subreddit.log_action 'Sidebar update failed', data: { honeybadger_id: id }
    end

    def show_sidebar(name)
      name_to_subreddit(name).generate_sidebar
    end
  end
end
