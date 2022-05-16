# frozen_string_literal: true

# :notest:
module Authenticate
  extend ActiveSupport::Concern

  included do
    before_action :setup_current_user, :add_honeybadger_context
  end

  def add_honeybadger_context
    return unless Current.user

    Honeybadger.context(
      user_id: Current.user.id,
      username: Current.user.username
    )
  end

  def setup_current_user
    return unless logged_in?

    Current.user = current_user
  end

  def not_authenticated
    respond_to do |format|
      format.html do
        flash[:error] = t 'sessions.log_in.please_log_in'
        redirect_to login_path
      end

      format.any do
        head :unauthorized
      end
    end
  end
end
