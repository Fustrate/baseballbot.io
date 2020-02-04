# frozen_string_literal: true

class SubredditsUser < ApplicationRecord
  belongs_to :subreddit
  belongs_to :user
end
