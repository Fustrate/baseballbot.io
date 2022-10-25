# frozen_string_literal: true

class SessionsController < ApplicationController
  def new = (redirect_to root_path if logged_in?)

  def create
    user = login params[:username], params[:password], params[:remember_me]

    user ? successful_login(user) : user_not_found
  end

  def destroy
    logout

    redirect_to login_path, flash: { info: t('sessions.logged_out') }
  end

  protected

  def user_not_found
    flash.now[:error] = t('sessions.log_in.failed')

    render :new
  end

  def successful_login(user)
    flash.now[:success] = t 'sessions.log_in.welcome_back', name: user.username

    redirect_back_or_to root_url
  end
end
