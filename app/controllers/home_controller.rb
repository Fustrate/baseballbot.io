# frozen_string_literal: true

# Home page, full of nothing right now
class HomeController < ApplicationController
  def home
    @gamechats = Gamechat
      .where('DATE(post_at) = ?', Time.zone.today)
      .includes(:subreddit)
  end
end
