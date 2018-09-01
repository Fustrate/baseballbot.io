# frozen_string_literal: true

class GameThread < ApplicationRecord
  belongs_to :subreddit

  default_scope { order(:starts_at) }
end
