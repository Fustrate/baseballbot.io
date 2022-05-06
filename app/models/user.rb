# frozen_string_literal: true

class User < ApplicationRecord
  include Editable::User
  include Eventable::User

  authenticates_with_sorcery!

  validates :username, uniqueness: true, presence: true, allow_blank: false
  validates :password, presence: true, on: :create, allow_blank: false

  alias_attribute :to_s, :username

  has_many :subreddit_users, dependent: :destroy
  has_many :subreddits, through: :subreddit_users

  def subreddit_ids
    @subreddit_ids ||= subreddits.ids
  end
end
