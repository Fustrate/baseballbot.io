# frozen_string_literal: true

class GameThreadsController < ApplicationController
  before_action :require_login, except: %i[index show]
  before_action :load_game_thread, except: %i[index new create]

  def index
    respond_to do |format|
      format.html
      format.json do
        @pagination, @game_threads = GameThreads::LoadPage.call
      end
    end
  end

  def show
  end

  def new
    @game_thread = GameThread.new
  end

  def edit
  end

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

  def load_game_thread
    @game_thread = GameThread.find params[:id]
  end
end
