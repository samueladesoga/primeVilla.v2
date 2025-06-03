class AddFirstNameLastNamePhoneNumberParentNameParentPhoneNumberToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone_number, :string
    add_column :users, :parent_name, :string
    add_column :users, :parent_phone_number, :string
  end
end
