class RemoveGidFromGamechats < ActiveRecord::Migration[5.1]
  def change
    remove_index :gamechats, column: %i[gid subreddit_id], unique: true
    add_index :gamechats, %i[game_pk subreddit_id], unique: true

    remove_column :gamechats, :gid, :string
  end
end
