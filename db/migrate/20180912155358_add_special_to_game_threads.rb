class AddSpecialToGameThreads < ActiveRecord::Migration[5.2]
  def change
    add_column :game_threads, :special, :string, default: nil

    remove_index :game_threads,
                 name: 'index_gamechats_on_game_pk_subreddit_date_unique'

    add_index :game_threads,
              "game_pk, subreddit_id, date_trunc('day', starts_at), special",
              name: "index_game_threads_on_game_pk_subreddit_date_special_unique",
              unique: true
  end
end
