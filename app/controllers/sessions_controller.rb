# frozen_string_literal: true

# Just use Reddit to log in, there's no need to maintain separate passwords and whatnot. If you can access a reddit
# account, you can update its subreddits.
class SessionsController < ApplicationController
  AUTH_SCOPE = %i[identity mysubreddits].freeze

  def new
    redirect_to auth_url, status: :moved_permanently, allow_other_host: true
  end

  def destroy
    logout

    redirect_to :app
  end

  def authorized
    user = Users::AuthorizedWithReddit.call

    auto_login(user, true)

    redirect_to :app
  end

  protected

  def auth_url
    session[:state] = SecureRandom.urlsafe_base64

    Redd.url(
      client_id: Rails.application.credentials.dig(:reddit_login, :client_id),
      redirect_uri: Rails.application.credentials.dig(:reddit_login, :redirect_uri),
      response_type: 'code',
      state: session[:state],
      scope: AUTH_SCOPE,
      duration: 'permanent'
    )
  end
end
