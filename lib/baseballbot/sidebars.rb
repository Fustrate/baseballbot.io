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

      @db.exec(SUBREDDITS_WITH_SIDEBARS_QUERY).each do |row|
        next unless names.empty? || names.include?(row['name'].downcase)

        update_sidebar! subreddits[row['name']]
      end
    end

    def update_sidebar!(name)
      subreddit = name_to_subreddit(name)

      description = subreddit.generate_sidebar

      subreddit.modify_settings description: description
    rescue Redd::InvalidAccess
      refresh_access!

      subreddit.modify_settings description: description
    rescue => ex
      Honeybadger.notify(ex, context: { name: name, description: description })
    end
  end
end
