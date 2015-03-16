class AddGamechats < ActiveRecord::Migration
  def change
    create_table :gamechats do |t|
      t.string :gid
      t.string :account
      t.string :subreddit
      t.datetime :post_at
      t.datetime :starts_at
      t.string :status
      t.string :title
      t.string :post_id

      t.timestamps
    end
  end
end
