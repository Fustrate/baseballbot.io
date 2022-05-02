# frozen_string_literal: true

module Users
  class Create < ApplicationService
    def call
      raise UserError, 'Passwords do not match' unless params[:password] == params[:confirm_password]

      User.create! username: verified_username, password: params[:password]
    end

    protected

    def verified_username = EncryptedMessages.new.decrypt_and_verify(params[:token], purpose: :username)
  end
end
