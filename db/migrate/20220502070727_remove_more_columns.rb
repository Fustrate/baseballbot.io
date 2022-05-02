class RemoveMoreColumns < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :lock_expires_at, :datetime
    remove_column :users, :failed_logins_count, :integer, default: 0
    remove_column :users, :unlock_token, :string, index: true
  end
end
