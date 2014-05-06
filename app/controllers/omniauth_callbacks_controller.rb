class User::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def twitter
    data = session["devise.omniauth_data"] = User.build_twitter_auth_cookie_hash(request.env["omniauth.auth"])

    user = User.find_for_twitter_oauth(data, current_user)
    # user = User.find_for_twitter_oauth(request.env["omniauth.auth"],current_user)
    if user.confirmed? # already registered, login automatically
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
      sign_in_and_redirect user, :event => :authentication
    elsif !user.email?
      flash[:error] = "You must add an email to complete your registration."
      @user = user
      render :add_email
    else
      # flash[:notice] = "Please confirm your email first to continue."
      # redirect_to new_user_confirmation_path
      # access_days = get_unconfirmed_access_days(User.get_unconfirmed_access_days)
      # flash[:notice] = "Unconfirmed access allowed for #{access_days[0]} days since registration."
      sign_in_and_redirect user, :event => :authentication
    end
  end

  def google_oauth2
    @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)
 
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def get_unconfirmed_access_days(s)
    [60,60,24].reduce([s]) { |m,o| m.unshift(m.shift.divmod(o)).flatten }
  end

  # need to figure out how to return the user to the reviews form
  # def after_sign_in_path_for(resource)
  #   return request.referrer || session[:user_return_to] || params[:return_to] || root_path
  # end
end