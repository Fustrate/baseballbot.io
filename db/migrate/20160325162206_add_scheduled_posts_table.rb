class AddScheduledPostsTable < ActiveRecord::Migration
  def change
    create_table :scheduled_posts do |t|
      t.datetime :next_post_at
      t.string   :title
      t.text     :body
      t.integer  :subreddit_id, null: false
      t.json     :options
    end
  end
end
