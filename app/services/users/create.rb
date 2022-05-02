# frozen_string_literal: true

module Users
  class Create < ApplicationService
    def call
      raise UserError, 'Passwords do not match' unless params[:password] == params[:confirm_password]

      @user = User.create! username: verified_username, password: params[:password]

      connect_subreddits

      @user
    end

    protected

    def verified_username = EncryptedMessages.new.decrypt_and_verify(params[:token], purpose: :username)

    def connect_subreddits
      Subreddit.where('? = ANY(moderators)', @user.username.downcase).ids.each do |subreddit_id|
        SubredditsUser.create(subreddit_id:, user_id: @user.id)
      end
    end
  end
end
