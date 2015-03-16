class RemoveAccountColumn < ActiveRecord::Migration
  def up
    remove_column :gamechats, :account
  end

  def down
    add_column :gamechats, :account, :string
  end
end
