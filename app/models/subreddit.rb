# frozen_string_literal: true

class Subreddit < ApplicationRecord
  include Authorizable
  include Editable
  include Eventable

  has_many :game_threads, dependent: :destroy
  has_many :templates, dependent: :destroy

  belongs_to :bot

  has_many :subreddits_users, dependent: :destroy
  has_many :users, through: :subreddits_users

  def url = "https://reddit.com/r/#{name}"

  # TODO: These are required for SubredditAuror to work. Make it work without them.

  def subreddit = self

  def subreddit_id = id
end
