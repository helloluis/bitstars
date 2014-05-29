class CreatePayouts < ActiveRecord::Migration
  def change
    create_table :payouts do |t|
      t.integer :user_id
      t.boolean :payout_to_charity
      t.text    :charity
      t.float   :amount_in_sats
      t.text    :earnings_breakdown
      t.text    :transaction_hash
      t.timestamps
    end
  end
end
