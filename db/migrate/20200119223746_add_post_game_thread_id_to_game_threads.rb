class AddPostGameThreadIdToGameThreads < ActiveRecord::Migration[6.0]
  def change
    add_column :game_threads, :pre_game_post_id, :string
    add_column :game_threads, :post_game_post_id, :string
  end
end
