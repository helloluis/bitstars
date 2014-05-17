class LandingController < ApplicationController

  def index
    @photos = Photo.today
    @with_position = true
  end

end