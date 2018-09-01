# frozen_string_literal: true

class Subreddit < ApplicationRecord
  has_many :game_threads, dependent: :destroy
  has_many :templates, dependent: :destroy

  belongs_to :account

  def url
    "http://reddit.com/r/#{name}"
  end

  def update_sidebar?
    @update_sidebar ||= options['sidebar'].try(:[], 'enabled')
  end

  def post_game_threads?
    @post_game_threads ||= options['game_threads'].try(:[], 'enabled')
  end

  def post_pregame?
    @post_pregame ||= options['pregame'].try(:[], 'enabled')
  end

  def post_postgame?
    @post_postgame ||= options['postgame'].try(:[], 'enabled')
  end
end
