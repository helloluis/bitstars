class LandingController < ApplicationController

  def index
    @photos = Photo.today
    @with_position = true
    @photos_yesterday = Photo.yesterday(10)
  end

end