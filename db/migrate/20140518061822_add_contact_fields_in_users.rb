class AddContactFieldsInUsers < ActiveRecord::Migration
  def change
    add_column :users, :phone,        :string
    add_column :users, :address,      :string
    add_column :users, :city,         :string
    add_column :users, :country,      :string
    add_column :users, :postal_code,  :string
  end
end
