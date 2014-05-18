class AddStatusToTips < ActiveRecord::Migration
  def change
    add_column :tips, :status, :integer, :default => 0
  end
end
