class AddCountersInUsers < ActiveRecord::Migration
  def change
    add_column :users, :num_likes,  :integer, default: 0
    add_column :users, :num_views,  :integer, default: 0
    add_column :users, :num_photos, :integer, default: 0
    add_column :users, :num_tips,   :integer, default: 0
  end
end
