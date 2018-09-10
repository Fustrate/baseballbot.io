# frozen_string_literal: true

# Home page, full of nothing right now
class HomeController < ApplicationController
  def home
    @game_threads = GameThread
      .where('DATE(post_at) = ?', Time.zone.today)
      .includes(:subreddit)
  end

  def gameday
    render :gameday, layout: nil
  end
end
