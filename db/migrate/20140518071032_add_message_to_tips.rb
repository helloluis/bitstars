class AddMessageToTips < ActiveRecord::Migration
  def change
    add_column :tips, :message, :string
  end
end
