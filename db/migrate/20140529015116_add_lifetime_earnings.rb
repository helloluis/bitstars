class AddLifetimeEarnings < ActiveRecord::Migration
  def change
    add_column :users, :lifetime_tips, :float, default: 0.0
    add_column :users, :lifetime_winnings, :float, default: 0.0
    add_column :users, :lifetime_earnings, :float, default: 0.0
  end
end
