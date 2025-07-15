# frozen_string_literal: true

# Home page, full of nothing right now
module Api
  class HomeController < ApplicationController
    # Sort by today's games, posted games, future games,
    DEFAULT_ORDER = Arel.sql(<<~SQL.squish)
      status = 'External' ASC,
      status = 'Posted' DESC,
      status = 'Pregame' DESC,
      status = 'Future' DESC,
      status IN ('Over', 'Postponed', 'Removed') ASC,
      post_at > NOW() DESC,
      starts_at ASC
    SQL

    def home
      @game_threads = GameThread
        .where('DATE(post_at) = ?', Time.zone.today)
        .includes(:subreddit)
        .order(DEFAULT_ORDER)
    end
  end
end
