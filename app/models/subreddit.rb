# frozen_string_literal: true

class Subreddit < ApplicationRecord
  has_many :game_threads, dependent: :destroy
  has_many :templates, dependent: :destroy

  belongs_to :account

  has_many :subreddit_users, dependent: :destroy
  has_many :users, through: :subreddit_users

  def url = "https://reddit.com/r/#{name}"

  def update_sidebar?
    @update_sidebar ||= options.dig('sidebar', 'enabled')
  end

  def post_game_threads?
    @post_game_threads ||= options.dig('game_threads', 'enabled')
  end

  def post_pregame?
    @post_pregame ||= options.dig('pregame', 'enabled')
  end

  def post_postgame?
    @post_postgame ||= options.dig('postgame', 'enabled')
  end
end
