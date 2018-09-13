# frozen_string_literal: true

class GameThreadsController < ApplicationController
  before_action :load_game_thread, except: %i[index new create]

  def index
    respond_to do |format|
      format.html
      format.json do
        @game_threads = GameThread
          .where('DATE(starts_at) = ?', Time.zone.today)
          .includes(:subreddit)
      end
    end
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  protected

  def load_game_thread
    @game_thread = GameThread.find params[:id]
  end
end
