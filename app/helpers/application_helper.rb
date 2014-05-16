module ApplicationHelper
  def page_title
    "#{App.name} || #{@page_title}"
  end

  def already_entered?(photo, provider='instagram')
    "already_entered" if Photo.already_entered?(current_user.id, provider, photo.id)
  end

  def liked?(photo)
    "liked" if photo.liked_by?(current_user)
  end
end
