# frozen_string_literal: true

# Copyright (c) 2022 Valencia Management Group
# All rights reserved.

module Users
  class Create < ApplicationService
    def call
      raise UserError, 'Invalid username' unless session[:reddit_username] == params[:username]

      raise UserError, 'Passwords do not match' unless params[:password] == params[:confirm_password]

      User.create! username: session[:reddit_username], password: params[:password]
    end
  end
end
