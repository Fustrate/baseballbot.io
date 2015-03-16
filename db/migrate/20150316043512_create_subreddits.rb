class CreateSubreddits < ActiveRecord::Migration
  def up
    create_table :subreddits do |t|
      t.string :name
      t.string :team_code
      t.integer :account_id
    end

    remove_column :gamechats, :subreddit
    add_column :gamechats, :subreddit_id, :integer, null: false
  end

  def down
    remove_table :subreddits
    remove_column :gamechats, :subreddit_id
    add_column :gamechats, :subreddit, :string
  end
end
