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

        update_sidebar! @subreddits[row['name']]
      end
    end

    def update_sidebar!(team)
      subreddit = team_to_subreddit(team)

      subreddit.update description: subreddit.generate_sidebar
    rescue Redd::InvalidAccess
      puts "Could not update #{subreddit.name} due to invalid credentials:"
      puts "\tExpires: #{current_account.access.expires_at.strftime '%F %T'}"
      puts "\tCurrent: #{Time.now.strftime '%F %T'}"

      refresh_access!

      puts "\tExpires: #{current_account.access.expires_at.strftime '%F %T'}"

      subreddit.update description: subreddit.generate_sidebar
    rescue Redd::ServerError, ::OpenURI::HTTPError
      # do nothing, it's not the end of the world
      nil
    rescue => ex
      Honeybadger.notify(ex, context: { team: team })
    end
  end
end
