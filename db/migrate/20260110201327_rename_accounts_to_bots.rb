# frozen_string_literal: true

class RenameAccountsToBots < ActiveRecord::Migration[8.1]
  def change
    rename_table :accounts, :bots
    rename_column :subreddits, :account_id, :bot_id
  end
end
