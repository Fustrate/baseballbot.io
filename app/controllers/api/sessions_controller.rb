# frozen_string_literal: true

module Api
  class SessionsController < ApplicationController
    def show
      render json: logged_in? ? logged_in_session_data : logged_out_session_data
    end

    protected

    def logged_in_session_data
      {
        loggedIn: true,
        user: {
          id: current_user.id,
          username: current_user.username,
          subreddits: current_user.subreddit_ids
        }
      }
    end

    def logged_out_session_data
      {
        loggedIn: false
      }
    end
  end
end
