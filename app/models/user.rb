# frozen_string_literal: true

class User < ApplicationRecord
  include Editable::User
  include Eventable::User

  authenticates_with_sorcery!

  has_many :subreddits_users, dependent: :destroy
  has_many :subreddits, through: :subreddits_users

  validates :username, uniqueness: true, presence: true, allow_blank: false
  validates :password, presence: true, on: :create, allow_blank: false

  alias_attribute :to_s, :username

  delegate :permission?, to: :user_permissions

  def subreddit_ids
    @subreddit_ids ||= subreddits.ids
  end

  # TODO: Make this a database column
  def permissions = {}

  def user_permissions
    @user_permissions ||= Users::Permissions.new(self)
  end
end
