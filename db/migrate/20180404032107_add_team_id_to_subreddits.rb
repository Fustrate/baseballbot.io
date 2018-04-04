class AddTeamIdToSubreddits < ActiveRecord::Migration[5.1]
  def change
    add_column :subreddits, :team_id, :integer
  end
end
