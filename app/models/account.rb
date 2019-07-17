# frozen_string_literal: true

class Account < ApplicationRecord
  has_many :subreddits, dependent: :nullify

  # Use this method to make sure we refresh expired tokens and save the new ones
  # def with_access
  #   return unless block_given?
  #
  #   reddit.with(access) do |client|
  #     if access.expired?
  #       client.refresh_access!
  #
  #       update access_token: access_token, expires_at: expires_at
  #     end
  #
  #     yield client
  #   end
  # end

  def access
    @access ||= Redd::Models::Access.new(
      access_token: access_token,
      refresh_token: refresh_token,
      scope: scope,
      expires_at: expires_at - 15
      expires_in: expires_at - Time.zone.now
    )
  end
end
