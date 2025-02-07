class AddTitleToTemplates < ActiveRecord::Migration[7.2]
  def change
    add_column :templates, :title, :string
  end
end
