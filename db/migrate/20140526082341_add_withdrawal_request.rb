class AddWithdrawalRequest < ActiveRecord::Migration
  def change
    add_column :users, :requesting_withdrawal, :boolean, default: true
    add_column :users, :requested_withdrawal_on, :datetime
  end
end
