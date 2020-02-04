class AddForeignKeys < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :templates, :subreddits
  end
end
