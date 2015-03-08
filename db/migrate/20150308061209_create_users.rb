class CreateUsers < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :subreddit
      t.string :access_token
      t.string :refresh_token, null: true
      t.string :scope, array: true, default: []
      t.datetime :expires_at
    end
  end
end
