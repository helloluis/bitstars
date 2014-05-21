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

  def already_flagged?(photo)
    return false if user_signed_in? || !photo
    App.flag_reasons.each do |reason|
      return "already_flagged" if photo.flagged_by?(current_user, reason.slug)
    end
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

  def facebook_link(css_class="",img=false)
    "<a href='http://facebook.com/#{App.services.facebook.username}' style='text-decoration: none; line-height:4;vertical-align:middle; display:inline-block;padding-right:10px;padding-left:10px; font-size:13px; color:#fff; text-transform: uppercase;' class='#{css_class}' title='Kreyos on Facebook'>#{img}Facebook</a>"
  end

  def twitter_link(css_class="",img=false)
    "<a href='http://twitter.com/#{App.services.twitter.username}' style='text-decoration: none;  line-height:4;vertical-align:middle; display:inline-block;padding-right:10px;padding-left:10px; font-size:13px; color:#fff; text-transform: uppercase;' class='#{css_class}' title='Kreyos on Twitter'>#{img}Twitter</a>"
  end

  def pinterest_link(css_class="",img=false)
    "<a href='http://pinterest.com/#{App.services.pinterest.username}' style='text-decoration: none;  line-height:4;vertical-align:middle; display:inline-block;padding-right:10px;padding-left:10px; font-size:13px; color:#fff; text-transform: uppercase;' class='#{css_class}' title='Kreyos on Pinterest'>#{img}Pinterest</a>"
  end

  def googleplus_link(css_class="",img=false)
    "<a href='http://plus.google.com/#{App.services.googleplus.username}' style='text-decoration: none;  line-height:4;vertical-align:middle; display:inline-block;padding-right:10px;padding-left:10px; font-size:13px; color:#fff; text-transform: uppercase;' class='#{css_class}' title='Kreyos on Google+'>#{img}Google+</a>"
  end

  def charity_info(charity_slug)
    if charity = App.charities.find{|c| c[:slug]==charity_slug }
      str = ""
      str << content_tag(:h3, link_to(charity.name, charity.url), class: 'charity-name' )
      str << content_tag(:p, charity.description, class: 'charity-description')
      str
    end
  end
end
