class AddGamechatOptionsToSubreddits < ActiveRecord::Migration
  def change
    add_column :subreddits, :gamechat_options, :json
  end
end
