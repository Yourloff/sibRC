class CreateActs < ActiveRecord::Migration[7.2]
  def change
    create_table :acts do |t|
      t.references :client, null: false, foreign_key: true
      t.references :template, null: false, foreign_key: true

      t.timestamps
    end
  end
end
