class RedoUsersColumns < ActiveRecord::Migration[7.0]
  def up
    enable_extension 'citext'

    remove_index :users, %i[email]
    remove_index :users, %i[reset_password_token]
    remove_column :users, :email, :string, null: false
    change_column :users, :username, :citext
    remove_column :users, :reset_password_email_sent_at, :datetime, precision: 6
    remove_column :users, :reset_password_token_expires_at, :datetime, precision: 6
    remove_column :users, :access_count_to_reset_password_page, :integer, default: 0
    remove_column :users, :reset_password_token, :string
  end

  def down
  end
end
