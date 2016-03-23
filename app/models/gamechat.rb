# frozen_string_literal: true
class Gamechat < ActiveRecord::Base
  belongs_to :subreddit

  default_scope { order(:starts_at) }
end
