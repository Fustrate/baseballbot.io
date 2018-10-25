class CreateSubredditsUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :subreddit_users, id: false do |t|
      t.references :subreddit, null: false
      t.references :user, null: false
    end
  end
end
