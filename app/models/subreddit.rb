class Subreddit < ActiveRecord::Base
  has_many :gamechats
  belongs_to :account

  def url
    "http://reddit.com/r/#{name}"
  end

  def update_sidebar?
    @update_sidebar ||= subreddit.options['sidebar'].try(:[], 'enabled')
  end

  def post_gamechats?
    @post_gamechats ||= subreddit.options['gamechats'].try(:[], 'enabled')
  end

  def post_pregame?
    @post_pregame ||= subreddit.options['pregame'].try(:[], 'enabled')
  end

  def post_postgame?
    @post_postgame ||= subreddit.options['postgame'].try(:[], 'enabled')
  end
end
