class AddGamePkToGamechats < ActiveRecord::Migration[5.1]
  def change
    add_column :gamechats, :game_pk, :integer
  end
end
