# frozen_string_literal: true

require 'mlb_stats_api'

class SubredditsController < ApplicationController
  def index
    @api = ::MLBStatsAPI::Client.new(
      logger: Rails.logger,
      cache: Rails.application.redis
    )

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
