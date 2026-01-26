# frozen_string_literal: true

class AddTypeToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :type, :string, default: 'user', null: false
  end
end
