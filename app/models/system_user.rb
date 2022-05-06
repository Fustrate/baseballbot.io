# frozen_string_literal: true

# System Users are used to track actions taken by an automated process.
class SystemUser < ApplicationRecord
  include Editable::User
  include Eventable::User

  validates :username, presence: true

  alias_attribute :to_s, :username

  def self.baseballbot
    @baseballbot ||= find 1
  end
end
