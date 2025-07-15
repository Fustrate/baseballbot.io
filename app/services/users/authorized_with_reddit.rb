# frozen_string_literal: true

module Users
  class AuthorizedWithReddit < ApplicationService
    def call
      validate!

      @user = User.find_or_initialize_by username: reddit_session.me.name

      initial_setup unless @user.persisted?

      @user
    end

    protected

    def validate!
      raise UserError, 'Invalid authorization code' unless params[:state] && params[:code]

      raise UserError, 'Invalid session' unless params[:state] == session[:state]
    end

    def reddit_session
      Redd.it(
        code: params[:code],
        client_id: Rails.application.credentials.dig(:reddit_login, :client_id),
        secret: Rails.application.credentials.dig(:reddit_login, :secret),
        redirect_uri: Rails.application.credentials.dig(:reddit_login, :redirect_uri)
      )
    end

    def initial_setup
      @user.password = SecureRandom.base58(64)

      Subreddit.where('? = ANY(moderators)', @user.username.downcase).ids.each do |subreddit_id|
        @user.subreddits.new(subreddit_id:)
      end

      @user.save!
    end
  end
end
