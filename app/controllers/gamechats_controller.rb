# frozen_string_literal: true

class GamechatsController < ApplicationController
  before_action :load_gamechat, except: %i(index new create)

  def index
    @gamechats = Gamechat.where('DATE(starts_at) = ?', Time.zone.today)
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

  def load_gamechat
    @gamechat = Gamechat.find params[:id]
  end
end
