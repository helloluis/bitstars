class RecountPhotosAndLikes < ActiveRecord::Migration
  def change
    User.all.each do |user|
      num_likes = 0
      num_photos = user.photos.length
      user.photos.each do |photo|
        num_likes += (photo.num_likes||0)
      end
      user.update_attributes(num_likes: num_likes, num_photos: num_photos)
    end
  end
end
