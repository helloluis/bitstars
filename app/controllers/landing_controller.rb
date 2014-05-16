class LandingController < ApplicationController

  def index
    @photos = Photo.today
  end

end