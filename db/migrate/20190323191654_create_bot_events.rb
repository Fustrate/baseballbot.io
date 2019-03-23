class CreateBotEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :bot_actions do |t|
      t.references :subject, polymorphic: true, null: false
      t.string :action, null: false
      t.string :note
      t.json :data

      t.datetime :date, default: -> { "now()" }
    end
  end
end
