# frozen_string_literal: true

require 'mlb_stats_api'

class SubredditsController < ApplicationController
  before_action :load_api

  def index
    @subreddits = Subreddit.order(:name).includes(:account)
  end

  def show
    @subreddit = load_subreddit
  end

  protected

  def load_api
    @api = ::MLBStatsAPI::Client.new(
      logger: Rails.logger,
      cache: Rails.application.redis
    )
  end

  def load_subreddit
    return Subreddit.find(params[:id]) if /\A\d+\z/.match?(params[:id])

    Subreddit.find_by(name: params[:id].to_s.downcase)
  end
end
