class RenameSpecialToType < ActiveRecord::Migration[5.2]
  def change
    rename_column :game_threads, :special, :type
    rename_index :game_threads,
                 :index_game_threads_on_game_pk_subreddit_date_special_unique,
                 :index_game_threads_on_game_pk_subreddit_date_type_unique
  end
end
