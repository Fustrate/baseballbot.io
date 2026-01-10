# frozen_string_literal: true

require 'mlb_stats_api'

module Api
  class SubredditsController < ApplicationController
    before_action :load_api

    before_action :load_subreddit, except: %i[index]

    def index
      @subreddits = Subreddit.order(:name).includes(:bot)
    end

    def show; end

    def update
      Subreddits::Update.call @subreddit

      render :show
    end

    def game_threads
      @pagination, @game_threads = GameThreads::LoadPage.call(scope: @subreddit.game_threads)
    end

    protected

    def load_api
      @api = ::MLBStatsAPI::Client.new(
        logger: Rails.logger,
        cache: Rails.application.redis
      )
    end

    def load_subreddit
      @subreddit = if /\A\d+\z/.match?(params[:id])
                     Subreddit.find(params[:id])
                   else
                     Subreddit.find_by(name: params[:id].to_s.downcase)
                   end
    end
  end
end
