Showboarder::Application.routes.draw do

  devise_for :users, :path => '/users', :controllers => { :sessions => "users/sessions", :registrations => "users/registrations", :omniauth_callbacks => "users/omniauth_callbacks" }
  root to: 'static_pages#home'
  match '/about',   to: 'static_pages#about',   via: 'get'
  
  match '/status/:guid'      => 'sales#status',   via: :get,  as: :status
  # match '/card_status/:guid' => 'cards#status',   via: :get,  as: :card_status
  match '/confirm/:guid'     => 'sales#show',     via: :get,  as: :confirm
  # match '/card/:guid' => 'cards#show', via: :get, as: :card
  match '/esuggest/:act', to: 'acts#esuggest', via: 'get'
  match '/eretrieve/:act', to: 'acts#eretrieve', via: 'get'

  resources :users, only: [:show] do
    # match '/boards' => 'users#boards', via: :get
    match '/stripe-connect' => 'users#stripe_connect', via: :get
  end

  resources :boards, only: [:create]

  resources :boards, except: [:index, :create], path:'' do
    # match '/payout' => 'boards#payout', via: :get
    # match '/payout' => 'sales#payout', via: :post
    # match '/ticketed'    => 'boards#ticketed',      via: :get
    match '/ticketed'    => 'boards#simple_ticketed',      via: :get
    # match '/ticketed'    => 'sales#board_ticketed',      via: :post
    resources :shows do
      # match '/ticketed'    => 'shows#ticketed',      via: :get
      # match '/ticketed'    => 'sales#show_ticketed',      via: :post
      match '/checkin', to: 'shows#checkin', via: :get
      match '/checkinattendee', to: 'shows#checkin_attendee', via: :post
      match '/checkoutattendee', to: 'shows#checkout_attendee', via: :post
      match '/attendees', to: 'shows#attendees', via: :get
      # match '/tickets', to: 'tickets#new', via: :get
      match '/checkout', to: 'shows#checkout', via: :get
      match '/checkout', to: 'sales#checkout', via: :post
      match '/reserve', to: 'tickets#reserve', via: :post
      # resources :charge, only: [:create]
    end
    resources :stages, only: [:create]
  end
  
  resources :stripe_events, only: [:create]
  # resources :cards, only: [:create]

  # get '/auth/stripe_connect/callback', to: 'users/omniauth_callbacks#stripe_connect'
  
  
  # mount StripeEvent::Engine => '/stripewebhook'

  # match ':id', to: 'boards#show', via: 'get'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
