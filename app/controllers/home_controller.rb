# Home page, full of nothing right now
class HomeController < ApplicationController
  def home
    Rails.logger.info ENV.keys.inspect if params[:debug]

    @gamechats = Gamechat
                 .where('DATE(post_at) = ?', Time.zone.today)
                 .includes(:subreddit)
  end
end
