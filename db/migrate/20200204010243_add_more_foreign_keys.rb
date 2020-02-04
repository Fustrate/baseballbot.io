class AddMoreForeignKeys < ActiveRecord::Migration[6.0]
  def change
    rename_table :subreddit_users, :subreddits_users

    add_foreign_key :subreddits, :accounts
    add_foreign_key :subreddits_users, :subreddits
    add_foreign_key :subreddits_users, :users

    add_foreign_key :scheduled_posts, :subreddits
    add_foreign_key :game_threads, :subreddits
  end
end
