class RemoveAccountsSubreddit < ActiveRecord::Migration
  def change
    remove_column :accounts, :subreddit, :string
  end
end
