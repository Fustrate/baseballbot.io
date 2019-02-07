# frozen_string_literal: true

class SessionsController < ApplicationController
  def log_in
  end

  def process_log_in
    email = params[:email].strip
    password = params[:password]
    remember_me = params[:remember_me]

    login(email, password, remember_me) do |account, failure_reason|
      return login_failure(failure_reason) unless account && !failure_reason

      redirect_to root_path
    end
  end

  def sign_out
    if logged_in?
      logout

      cookies.delete :homeowner_id
    end

    flash[:info] = t 'sessions.logged_out'

    redirect_to root_path
  end

  protected

  def login_failure(failure_reason)
    if failure_reason == :inactive
      flash[:error] = t 'sessions.activation.account_not_activated'

      redirect_to resend_activation_path(email: params[:email])

      return
    end

    flash[:error] = t 'sessions.log_in.failure'

    render :log_in
  end
end
