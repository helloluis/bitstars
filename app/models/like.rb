class Like < ActiveRecord::Base

  belongs_to :photo

  belongs_to :user

  validate :unique_like

  def unique_like
    errors.add(:base, "You've already liked that photo") if Like.where(["photo_id=? AND user_id=?", photo_id, user_id]).exists?
  end

  def self.like!(photo, user)
    self.create(photo: photo, user: user)
    photo.increment!(:num_likes)
  end

  def self.unlike!(photo, user)
    if like_record = photo.likes.where("user_id=?",user.id).first
      like_record.delete
      photo.decrement!(:num_likes)
    end
  end

  def self.ignore!(photo, user)
    self.where("photo_id=? AND user_id=?", photo.id, user.id).update_attributes(:disqualified => true)
    photo.decrement!(:num_likes)
  end

  def self.ignore_all_of_user(user)
    self.where(["user_id=?",user.id]).map(&:id).each do |id|
      Photo.find(id).decrement!(:num_likes)
    end
    self.where(["user_id=?",user.id]).update_all(:disqualified => true)
  end

end