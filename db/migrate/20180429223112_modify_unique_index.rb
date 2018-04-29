class ModifyUniqueIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index :gamechats, column: %i[game_pk subreddit_id], unique: true

    add_index :gamechats,
              "game_pk, subreddit_id, date_trunc('day', starts_at)",
              name: "index_gamechats_on_game_pk_subreddit_date_unique",
              unique: true
  end
end
