class AddPayoutTransactionFields < ActiveRecord::Migration
  def change
    add_column :payouts, :transaction_message, :string
    add_column :payouts, :transaction_hash, :string
    add_column :payouts, :transaction_notice, :string
  end
end
