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
    Current.user = logged_in? ? current_user : Guest.new
  end

  # This method is called when Sorcery denies access to a resource due to the user not being authenticated
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
