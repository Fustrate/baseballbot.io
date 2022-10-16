class RemoveTitleFromTemplates < ActiveRecord::Migration[7.0]
  def change
    remove_column :templates, :title, :string
  end
end
