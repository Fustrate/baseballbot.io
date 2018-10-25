class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :username,         null: false
      t.string :email,            null: false
      t.string :crypted_password
      t.string :salt

      # Brute Force Protection
      t.datetime :lock_expires_at,                    default: nil
      t.integer :failed_logins_count,                 default: 0
      t.string :unlock_token,                         default: nil

      # Activity Logging
      t.datetime :last_activity_at,                   default: nil
      t.datetime :last_login_at,                      default: nil
      t.datetime :last_logout_at,                     default: nil
      t.string :last_login_from_ip_address,           default: nil

      # Remember Me
      t.datetime :remember_me_token_expires_at,       default: nil
      t.string :remember_me_token,                    default: nil

      # Reset Password
      t.datetime :reset_password_email_sent_at,       default: nil
      t.datetime :reset_password_token_expires_at,    default: nil
      t.integer :access_count_to_reset_password_page, default: 0
      t.string :reset_password_token,                 default: nil

      t.timestamps null: false

      t.index :username, unique: true
      t.index :email, unique: true
      t.index [:last_logout_at, :last_activity_at]
      t.index :unlock_token
      t.index :remember_me_token
      t.index :reset_password_token
    end
  end
end
