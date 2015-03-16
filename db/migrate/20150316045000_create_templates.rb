class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.text :body
      t.string :type
      t.integer :subreddit_id

      t.timestamps
    end
  end
end
