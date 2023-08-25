# frozen_string_literal: true

class AddModmails < ActiveRecord::Migration[7.0]
  def change
    create_table :modmails do |t|
      t.string :reddit_id, unique: true
      t.string :subject
      t.bigint :thread_id
      t.string :username
      t.boolean :status

      t.timestamps
    end
  end
end
