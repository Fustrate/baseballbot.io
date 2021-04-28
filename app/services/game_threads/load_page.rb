# frozen_string_literal: true

module GameThreads
  class LoadPage < ApplicationService::LoadPage
    DEFAULT_INCLUDES = [:subreddit].freeze

    # Sort by today's games, posted games, future games,
    ORDER_SQL = Arel.sql(<<~SQL.squish)
      DATE(starts_at) = ? DESC,
      status = 'Posted' DESC,
      post_at > ? DESC,
      CASE WHEN post_at > ? THEN -(NOW() - starts_at) ELSE NOW() - starts_at END ASC
    SQL

    DEFAULT_ORDER = lambda do
      [ORDER_SQL, Time.zone.now, Time.zone.now, Time.zone.now]
    end

    protected

    def default_scope
      GameThread.all
    end
  end
end
