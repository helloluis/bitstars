class WinningsController < ApplicationController

  def index
    @winning_photos = current_user.photos.winners
  end

end