# frozen_string_literal: true

class AddOptionsToGameThreads < ActiveRecord::Migration[7.1]
  def change
    add_column :game_threads, :options, :jsonb, default: {}, null: false
  end
end
