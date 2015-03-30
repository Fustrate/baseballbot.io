class UniqueGidAndSubreddit < ActiveRecord::Migration
  def change
    add_index :gamechats, [:gid, :subreddit_id], unique: true
  end
end
