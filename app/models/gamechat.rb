# frozen_string_literal: true

class Gamechat < ApplicationRecord
  belongs_to :subreddit

  default_scope { order(:starts_at) }
end
