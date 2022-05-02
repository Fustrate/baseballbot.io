# frozen_string_literal: true

class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :username, uniqueness: true, presence: true, allow_blank: false
  validates :password, presence: true, on: :create, allow_blank: false

  alias_attribute :to_s, :username

  has_many :subreddit_users, dependent: :destroy
  has_many :subreddits, through: :subreddit_users
end
