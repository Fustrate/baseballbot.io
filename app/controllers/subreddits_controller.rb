class SubredditsController < ApplicationController
  def index
    @subreddits = Subreddit.order(:name).includes(:account)
  end
end
