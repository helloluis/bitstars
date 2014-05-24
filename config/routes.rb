Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  root 'landing#index'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  resources :users do 
    member do 
      get :callback_for_blockchain
    end
  end

  resources :tips do 
    member do 
      get :callback_for_blockchain
    end
    collection do
      get :sent
      get :request_withdrawal
    end
  end
  resources :winnings

  resources :photos do
    member do 
      get :heart
      get :unheart
      post :flag
      post :unflag
      get :set_winner
      get :unset_winner
      get :disqualify
      get :requalify
    end
    collection do 
      post :batch_create
      get  :winners
      get  :not_found
      get  "/:year/:month/:day" => "photos#by_date"
    end
  end

  get "/rules"   => "static#rules"
  get "/about"   => "static#about"
  get "/privacy" => "static#privacy"
  get "/contact" => "static#contact"

  get "/select_your_entries"  => "users#select_photos"
  get "/your_entries"         => "users#photos"
  get "/edit_profile"         => "users#edit"
  
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
