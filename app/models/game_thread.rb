# frozen_string_literal: true

class GameThread < ApplicationRecord
  include Authorizable
  include Editable
  include Eventable

  belongs_to :subreddit, optional: false

  TYPES = %w[no_hitter game_thread].freeze
  STATUSES = %w[Future Pregame Posted Over Removed Postponed Foreign].freeze

  TITLE_INTERPOLATION_STRINGS = %i[
    start_time start_time_et away_full_name away_name away_pitcher away_record home_full_name home_name home_pitcher
    home_record
  ].freeze

  TITLE_INTERPOLATION_INTEGERS = %i[series_game home_wins away_wins].freeze

  validates :game_pk, :post_at, :starts_at, :status, presence: true
  validates :type, inclusion: TYPES, allow_nil: true
  validates :status, inclusion: STATUSES
  validates :game_pk,
            uniqueness: { scope: %w[subreddit_id type], message: I18n.t('game_threads.errors.game_pk_exists') },
            on: :create
  validate :valid_title_format

  protected

  def valid_title_format
    format(
      title,
      {
        **TITLE_INTERPOLATION_STRINGS.to_h { [_1, ''] },
        **TITLE_INTERPOLATION_INTEGERS.to_h { [_1, 1] }
      }
    )
  rescue KeyError
    errors.add :title, I18n.t('game_threads.errors.title_invalid_tokens')
  end
end
