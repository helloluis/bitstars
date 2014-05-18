module ApplicationHelper
  def page_title
    "BITST&#10029;RS - #{@page_title || App.tagline}"
  end

  def already_entered?(photo, provider='instagram')
    "already_entered" if user_signed_in? && Photo.already_entered?(current_user.id, provider, photo['id'])
  end

  def liked?(photo)
    "liked" if user_signed_in? && photo.liked_by?(current_user)
  end

  def with_position?
    "photos_with_position" if @with_position
  end

  def position_class(pos)
    if pos==1
      "leader"
    elsif pos>=2 && pos <=5
      "top_5"
    elsif pos>5 && pos<=10
      "top_10"
    elsif pos>10 && pos<=20
      "top_20"
    end
  end
end
