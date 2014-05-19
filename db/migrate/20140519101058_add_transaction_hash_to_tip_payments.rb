class AddTransactionHashToTipPayments < ActiveRecord::Migration
  def change
    add_column :tip_payments, :transaction_hash, :string
    add_index :tip_payments, :transaction_hash
  end
end
