class RemoveSomeTipColumns < ActiveRecord::Migration
  def change
    remove_column :tips, :transaction_fee
    remove_column :tips, :amount_in_php
    remove_column :tips, :payment_details
  end
end
