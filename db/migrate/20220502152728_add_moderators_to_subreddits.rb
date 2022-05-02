class AddModeratorsToSubreddits < ActiveRecord::Migration[7.0]
  def change
    add_column :subreddits, :moderators, :string, array: true, default: []
  end
end
