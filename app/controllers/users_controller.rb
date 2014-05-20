class UsersController < ApplicationController

  before_filter :authenticate_user!, except: [ :show ]

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user].permit!)
      if @user.has_completed_profile?
        flash[:notice] = "Great! You've completed your profile and can now receive tips and contest winnings."
      else
        flash[:error] = "Your profile is still not complete. You won't be eligible to receive winnings or tips yet."
      end
      return redirect_to "/your_entries"
    else
      flash[:alert] = "There were some problems with saving your profile."
      render :action => :edit
    end
  end

  def select_photos
    @retrieved_photos = current_user.retrieve_photos
  rescue Koala::Facebook::AuthenticationError => e 
    flash[:error] = "Please login to Facebook again."
    redirect_to root_path
  end

  def photos
    @page = (params[:page] || 1).to_i
    @photos = current_user.photos.order("created_at DESC").page(params[:page]).per('30').group_by{|p| p.created_at.beginning_of_day}
  end

  def show
    @user = User.friendly.find(params[:id]) #find_by_username(params[:id])
    @photos = @user.photos.page(params[:page]).per('20')
  end

end