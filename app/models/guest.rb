# frozen_string_literal: true

class Guest
  def id = -1

  def username = 'Guest'

  def subreddit_ids = []

  def permissions = {}

  def user_permissions
    @user_permissions ||= Users::Permissions.new(self)
  end

  alias_attribute :to_s, :username

  delegate :permission?, to: :user_permissions
end
