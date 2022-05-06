# frozen_string_literal: true

module Users
  class Create < ApplicationService
    def call
      raise UserError, 'Passwords do not match' unless params[:password] == params[:confirm_password]

      @user = User.find_or_initialize_by username: verified_username

      existing_user = @user.persisted?

      @user.password = params[:password]

      @user.save!

      connect_subreddits unless existing_user

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
