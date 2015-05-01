class Subreddit < ActiveRecord::Base
  has_many :gamechats
  belongs_to :account

  def url
    "http://reddit.com/r/#{name}"
  end
end
