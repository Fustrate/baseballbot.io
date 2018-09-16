class AddPartialIndexToGameThreads < ActiveRecord::Migration[5.2]
  def change
    add_index :game_threads,
              "game_pk, subreddit_id, date_trunc('day'::text, starts_at)",
              unique: true,
              name: "index_game_threads_on_game_pk_subreddit_date_unique",
              where: 'type IS NULL'
  end
end
