class AddGamechatOptionsToSubreddits < ActiveRecord::Migration
  def change
    add_column :subreddits, :options, :json
  end
end
