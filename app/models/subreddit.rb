# frozen_string_literal: true

class Subreddit < ActiveRecord::Base
  has_many :gamechats
  belongs_to :account

  def url
    "http://reddit.com/r/#{name}"
  end

  def update_sidebar?
    @update_sidebar ||= options['sidebar'].try(:[], 'enabled')
  end

  def post_gamechats?
    @post_gamechats ||= options['gamechats'].try(:[], 'enabled')
  end

  def post_pregame?
    @post_pregame ||= options['pregame'].try(:[], 'enabled')
  end

  def post_postgame?
    @post_postgame ||= options['postgame'].try(:[], 'enabled')
  end
end
