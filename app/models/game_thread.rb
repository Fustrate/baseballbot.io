# frozen_string_literal: true

class GameThread < ApplicationRecord
  include Authorizable
  include Editable
  include Eventable

  belongs_to :subreddit, optional: false

  TYPES = %w[no_hitter game_thread].freeze
  STATUSES = %w[Future Pregame Posted Over Removed Postponed Foreign].freeze

  validates :game_pk, :post_at, :starts_at, :status, presence: true
  validates :type, inclusion: TYPES, allow_nil: true
  validates :status, inclusion: STATUSES
end
