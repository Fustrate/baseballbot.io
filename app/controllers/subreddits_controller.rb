# frozen_string_literal: true

class SubredditsController < ApplicationController
  def index
    @subreddits = Subreddit.order(:name).includes(:account)
  end

  def show
    @subreddit = load_subreddit
  end

  protected

  def load_subreddit
    return Subreddit.find(params[:id]) if /\A\d+\z/.match?(params[:id])

    Subreddit.find_by(name: params[:id].to_s.downcase)
  end
end
