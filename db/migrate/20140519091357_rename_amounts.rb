class RenameAmounts < ActiveRecord::Migration
  def change
    rename_column :tip_payments, :final_amount_in_btc, :final_amount_in_sats
    rename_column :tip_payments, :original_amount_in_btc, :original_amount_in_sats
    rename_column :tips, :actual_amount_in_btc, :actual_amount_in_sats
  end
end
