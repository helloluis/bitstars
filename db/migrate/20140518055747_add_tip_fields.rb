class AddTipFields < ActiveRecord::Migration
  def change
    add_column :tips, :invoice_address, :string
    add_column :tips, :paid, :boolean, default: false
    add_column :tips, :payment_details, :text
    add_column :tips, :actual_amount_in_btc, :float, default: 0.0
    add_index :tips, :invoice_address
  end
end
