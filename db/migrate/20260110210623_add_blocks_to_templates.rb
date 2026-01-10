class AddBlocksToTemplates < ActiveRecord::Migration[8.1]
  def change
    add_column :templates, :blocks, :json
  end
end
