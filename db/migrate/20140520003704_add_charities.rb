class AddCharities < ActiveRecord::Migration
  def change
    add_column :users, :payout_to_charity, :boolean, default: true
    add_column :users, :charity, :text, default: true
    add_index  :users, :payout_to_charity
  end
end
