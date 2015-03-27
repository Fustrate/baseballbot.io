class AddTitleToTemplates < ActiveRecord::Migration
  def change
    add_column :templates, :title, :string
  end
end
