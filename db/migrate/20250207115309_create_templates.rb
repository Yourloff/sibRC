class CreateTemplates < ActiveRecord::Migration[7.2]
  def change
    create_table :templates do |t|
      t.timestamps
    end
  end
end
