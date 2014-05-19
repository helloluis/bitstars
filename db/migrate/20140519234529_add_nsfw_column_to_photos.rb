class AddNsfwColumnToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :nsfw, :boolean, default: false
    add_index :photos, :nsfw
  end
end
