# Home page, full of nothing right now
class HomeController < ApplicationController
  def home
    @gamechats = Gamechat.where(status: 'Posted').includes(:subreddit)
  end
end
