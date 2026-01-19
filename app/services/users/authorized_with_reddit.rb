# frozen_string_literal: true

module Users
  class AuthorizedWithReddit < ApplicationService
    def call
      validate!

      @user = User.find_or_initialize_by username: reddit_session.me.name

      update_subreddits

      @user
    end

    protected

    def validate!
      raise UserError, 'Invalid authorization code' unless params[:state] && params[:code]

      raise UserError, 'Invalid session' unless params[:state] == session[:state]
    end

    def reddit_session
      @reddit_session ||= Redd.it(
        code: params[:code],
        client_id: Rails.application.credentials.dig(:reddit_login, :client_id),
        secret: Rails.application.credentials.dig(:reddit_login, :secret),
        redirect_uri: Rails.application.credentials.dig(:reddit_login, :redirect_uri)
      )
    end

    def update_subreddits
      moderated_subreddits = reddit_session.my_subreddits(:moderator, limit: 100).map(&:display_name)

      SubredditsUser.where(user: @user).delete_all if @user.persisted?

      Subreddit.where(name: moderated_subreddits).find_each do |subreddit|
        @user.subreddits_users.new(subreddit:)
      end

      @user.save!
    end
  end
end
