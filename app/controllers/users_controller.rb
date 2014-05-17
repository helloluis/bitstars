class UsersController < ApplicationController

  before_filter :authenticate_user!, except: [ :show ]

  def edit
    @user = current_user
  end

  def update
    current_user.update_attributes(params[:user])
  end

  def select_photos
    if client = Instagram.client(:access_token => current_user.access_token)
      @photos = client.user_recent_media(count: 30)
    else
      flash[:alert] = "Please login to Instagram again."
      sign_out_and_redirect current_user, root_path
    end
  end

  def photos
    @page = (params[:page] || 1).to_i
    @photos = current_user.photos.order("created_at DESC").page(params[:page]).per('30').group_by{|p| p.created_at.beginning_of_day}
  end

  def show
    @user = User.find_by_username(params[:id])
    @photos = @user.photos.page(params[:page]).per('20')
  end

end