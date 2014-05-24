class AddTotalTipsSent < ActiveRecord::Migration
  def change
    add_column :users, :total_tips_sent, :float, default: 0.0
  end
end
