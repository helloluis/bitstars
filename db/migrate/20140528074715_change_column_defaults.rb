class ChangeColumnDefaults < ActiveRecord::Migration
  def change
    change_column :users, :charity, :string, :default => ""
    change_column :users, :requesting_withdrawal, :boolean, :default => false
  end
end
