class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.references :eventable, polymorphic: true
      t.string :type
      t.string :note

      t.timestamps
    end
  end
end
