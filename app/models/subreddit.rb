class Subreddit < ActiveRecord::Base
  has_many :gamechats
  belongs_to :account
end
