class RenameGamechatsToGameThreads < ActiveRecord::Migration[5.2]
  def change
    rename_table :gamechats, :game_threads

    Template.where(type: 'gamechat').update_all(type: 'game_thread')
    Template.where(type: 'gamechat_update').update_all(type: 'game_thread_update')

    Template.connection.execute(<<~SQL)
      update subreddits
      set options = options::jsonb || jsonb_build_object('game_threads', (options::jsonb)->'gamechats')
      where options#>>'{gamechats}' IS NOT NULL
    SQL
  end
end
