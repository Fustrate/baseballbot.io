# frozen_string_literal: true

module Api
  class SignUpController < ApplicationController
    AUTH_SCOPE = %i[identity].freeze

    def start
      redirect_to_reddit
    end

    def authorized
      raise UserError, 'Invalid authorization code' unless params[:state] && params[:code]

      raise UserError, 'Invalid session' unless params[:state] == session[:state]

      authorized_with_reddit
    end

    def finish
      user = Users::Create.call

      auto_login(user, true)

      redirect_to :root
    end

    protected

    def redirect_to_reddit
      session[:state] = SecureRandom.urlsafe_base64

      auth_url = Redd.url(
        client_id: Rails.application.credentials.dig(:reddit_login, :client_id),
        redirect_uri: Rails.application.credentials.dig(:reddit_login, :redirect_uri),
        response_type: 'code',
        state: session[:state],
        scope: AUTH_SCOPE,
        duration: 'permanent'
      )

      redirect_to auth_url, status: :moved_permanently, allow_other_host: true
    end

    def authorized_with_reddit
      @user = User.find_or_initialize_by username: reddit_session.me.name
    end

    def reddit_session
      @reddit_session ||= Redd.it(
        code: params[:code],
        client_id: Rails.application.credentials.dig(:reddit_login, :client_id),
        secret: Rails.application.credentials.dig(:reddit_login, :secret),
        redirect_uri: Rails.application.credentials.dig(:reddit_login, :redirect_uri)
      )
    end
  end
end
