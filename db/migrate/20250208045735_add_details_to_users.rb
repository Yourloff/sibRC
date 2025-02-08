class AddDetailsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :birth_date, :date
    add_column :users, :gender, :string
    add_column :users, :position, :string
  end
end
