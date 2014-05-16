RailsAdmin.config do |config|

  ## == Devise ==
  
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method &:current_user

  ## == Cancan ==
  # config.authorize_with :cancan
  config.authorize_with do
    logger.info "!! #{user_signed_in?} !!"
    if user_signed_in?
      redirect_to main_app.new_user_session_url unless App.emails.values.include?(current_user.email)
    else
      redirect_to main_app.new_user_session_url
    end
  end
  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  config.model User do 
    list do 
      sort_by :created_at
      field :first_name
      field :last_name
      field :email
    end
  end

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
