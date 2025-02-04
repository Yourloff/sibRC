class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :inn
      t.string :kpp
      t.string :address
      t.string :customer
      t.string :phone

      t.timestamps
    end
  end
end
