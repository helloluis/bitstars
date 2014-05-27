module ApplicationHelper
  def page_title
    "BITST&#10029;RS - #{@page_title || App.tagline}"
  end

  def page_open_graph_tags
    str = ""
    if @photo
      str << content_tag(:meta,'',property:'og:title',content:"A selfie by #{@photo.user.username} on #{App.name}")
      str << content_tag(:meta,'',property:'og:type',content:"photo")
      str << content_tag(:meta,'',property:'og:description',content:@photo.description)
      str << content_tag(:meta,'',property:'og:image',content:@photo.images[:low])
      str << content_tag(:meta,'',property:'og:url',content:photo_url(@photo))
      str << content_tag(:meta,'',property:'twitter:card',content:'summary')
      str << content_tag(:meta,'',property:'twitter:site',content:App.services.twitter.username)
      str << content_tag(:meta,'',property:'twitter:title',content:"A selfie by #{@photo.user.username} on #{App.name}")
      str << content_tag(:meta,'',property:'twitter:description',content:@photo.description)
    else
      str << content_tag(:meta,'',property:'og:title',content:App.name)
      str << content_tag(:meta,'',property:'og:type',content:"website")
      str << content_tag(:meta,'',property:'og:description',content:App.tagline)
      str << content_tag(:meta,'',property:'og:image',content:asset_url('logo.png'))
      str << content_tag(:meta,'',property:'og:url',content:"http://#{App.url}")
      str << content_tag(:meta,'',property:'twitter:card',content:'summary')
      str << content_tag(:meta,'',property:'twitter:site',content:App.services.twitter.username)
      str << content_tag(:meta,'',property:'twitter:title',content:App.name)
      str << content_tag(:meta,'',property:'twitter:description',content:App.description)
    end
    str
  end

  def already_entered?(photo, provider='instagram')
    "already_entered" if user_signed_in? && Photo.already_entered?(current_user.id, provider, photo[:id])
  end

  def liked?(photo)
    "liked" if user_signed_in? && photo.liked_by?(current_user)
  end

  def already_flagged?(photo)
    return false if !user_signed_in? || !photo
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

  def two_days_ago
    2.days.ago.beginning_of_day
  end

  def photos_by_date_path(date)
    "/photos/#{date.strftime("%Y")}/#{date.strftime("%m")}/#{date.strftime("%d")}"
  end

  def user_is_admin?
    user_signed_in? && current_user.is_admin?
  end

  def to_mbtc(satoshis, no_unit=false)
    if no_unit
      number_with_precision(satoshis.to_i.to_f/10000)
    else
      [number_with_precision(satoshis.to_i.to_f/10000, precision: 2),"mBTC"].join(" ")
    end
  end

  def to_btc(satoshis, no_unit=false)
    if no_unit
      number_with_precision(satoshis.to_i.to_f/100000000, precision: 6)
    else
      [number_with_precision(satoshis.to_i.to_f/100000000, precision: 6),"BTC"].join(" ")
    end
  end

  def to_php(satoshis)
    number_to_currency(CurrencyExchangeRates.convert(to_btc(satoshis,true).to_f,'BTC','PHP'),unit: "PHP")
  end

  def development_status
    if App.development_status!='final'
      link_to image_tag("#{App.development_status}.png", class: 'development_status', title: "We're still in #{App.development_status}! Please forgive the clutter!").html_safe, "http://facebook.com/#{App.services.facebook.username}"
    end
  end
end
