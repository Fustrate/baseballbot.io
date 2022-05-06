class CreateEdits < ActiveRecord::Migration[7.0]
  def change
    create_table :edits do |t|
      t.references :editable, polymorphic: true, null: false, index: true
      t.references :user, polymorphic: true, null: false, index: true
      t.text :note
      t.string :reason
      t.jsonb :pretty_changes, default: {}, null: false
      t.jsonb :raw_changes, default: {}, null: false

      t.timestamps
    end

    add_column :events, :user_type, :string, null: false
    add_column :events, :user_id, :bigint, null: false

    add_index :events, %w[user_type user_id]

    create_table :system_users do |t|
      t.string :username, null: false
      t.string :description

      t.timestamps
    end
  end
end
