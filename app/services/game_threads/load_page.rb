# frozen_string_literal: true

module GameThreads
  class LoadPage < ApplicationService::LoadPage
    DEFAULT_INCLUDES = [:subreddit].freeze

    # Sort by today's games, posted games, future games,
    DEFAULT_ORDER = Arel.sql(<<~SQL.squish)
      DATE(starts_at) = CURRENT_DATE DESC,
      status = 'Posted' DESC,
      post_at > NOW() DESC,
      CASE WHEN post_at > NOW() THEN -(NOW() - starts_at) ELSE NOW() - starts_at END ASC
    SQL

    protected

    def default_scope
      GameThread.all
    end
  end
end
