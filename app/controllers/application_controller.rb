class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected
  
    def authenticate_admin!
      if user_signed_in?
        unless current_user.is_admin?
          flash[:alert] = "You are not an administrator."
          return redirect_to photo_path(@photo)
        end
      else
        return redirect_to photo_path(@photo)
      end
    end
end
