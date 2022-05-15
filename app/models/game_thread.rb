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
  validates :game_pk,
            uniqueness: { scope: %w[subreddit_id type], message: I18n.t('game_threads.errors.game_pk_exists') },
            on: :create
end
