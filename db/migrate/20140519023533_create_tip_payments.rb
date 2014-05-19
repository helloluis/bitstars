class CreateTipPayments < ActiveRecord::Migration
  def change
    create_table :tip_payments do |t|
      t.integer  :sender_id
      t.integer  :recipient_id
      t.integer  :tip_id
      t.text     :payment_details
      t.float    :original_amount_in_btc
      t.float    :final_amount_in_btc
      t.float    :transaction_fee
      t.boolean  :paid_out
      t.timestamps
    end
    add_index :tip_payments, :tip_id
    add_index :tip_payments, [:recipient_id, :tip_id]
    add_index :tip_payments, [:sender_id, :tip_id]
  end
end
