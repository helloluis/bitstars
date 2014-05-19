class RenameTipAddress < ActiveRecord::Migration
  def change
    rename_column :users, :tip_address, :wallet_address
  end
end
