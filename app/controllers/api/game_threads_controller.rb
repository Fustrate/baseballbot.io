# frozen_string_literal: true

module Api
  class GameThreadsController < ApplicationController
    before_action :require_login, except: %i[index show]
    before_action :load_game_thread, except: %i[index create]

    def index
      respond_to do |format|
        format.html
        format.json do
          @pagination, @game_threads = GameThreads::LoadPage.call(scope: game_threads_scope)
        end
      end
    end

    def show; end

    def create
      @game_thread = GameThreads::Create.call

      flash[:success] = t 'game_threads.created'

      redirect_to game_threads_subreddit_path(@game_thread.subreddit)
    rescue ActiveRecord::RecordInvalid => e
      @game_thread = e.record

      render :new
    end

    def update
      GameThreads::Update.call @game_thread

      flash[:success] = t 'game_threads.updated'

      redirect_to @game_thread
    rescue ActiveRecord::RecordInvalid
      render :new
    end

    def destroy
      GameThreads::Destroy.call @game_thread

      head :no_content
    end

    protected

    def game_threads_scope
      return GameThread.all if params[:date].blank?

      GameThread.where('DATE(starts_at) = ?', Date.iso8601(params[:date]))
    rescue Date::Error
      GameThread.all
    end

    def load_game_thread
      @game_thread = GameThread.find params[:id]
    end
  end
end
