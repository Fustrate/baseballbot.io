class GameThreadsDefaultCreatedAtUpdatedAt < ActiveRecord::Migration[5.2]
  def change
    change_column_default :game_threads, :created_at, -> { 'CURRENT_TIMESTAMP' }
    change_column_default :game_threads, :updated_at, -> { 'CURRENT_TIMESTAMP' }
  end
end
