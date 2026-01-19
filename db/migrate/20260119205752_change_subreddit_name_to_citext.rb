# frozen_string_literal: true

class ChangeSubredditNameToCitext < ActiveRecord::Migration[8.1]
  def change
    change_column :bots, :name, :citext
    change_column :subreddits, :name, :citext
  end
end
