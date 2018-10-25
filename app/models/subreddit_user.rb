# frozen_string_literal: true

class SubredditUser < ApplicationRecord
  belongs_to :subreddit
  belongs_to :user
end
