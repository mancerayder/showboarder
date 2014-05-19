Showboarder::Application.routes.draw do
  # get "show/new"
  # get "show/create"
  # get "show/show"
  # get "show/update"
  # get "show/destroy"
  # get "guests/new"
  # get "guests/create"
  # get "users/new"
  # devise_for :users do
  #   get "/signup", :to => "devise/registrations#new"
  # end

  
  # match '/buy/:permalink'    => 'transactions#create',   via: :post, as: :buy

  devise_for :users, :path => '/users', :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  root to: 'static_pages#home'

  resources :users, :guests

  resources :boards, path:'' do
    match '/subscribe'    => 'boards#subscribe',      via: :get
    match '/subscribe'    => 'transactions#subscribe',      via: :post
    # resources :subscribe, only: [:create]
    # match '/subscribe', to: 'subscribe#new', via: 'get'
    resources :shows do
      match '/charge'    => 'shows#charge',      via: :get
      match '/charge'    => 'transactions#charge',      via: :post
      # resources :tickets, only: [:create]
      # match '/reserve', to:'tickets#reserve', via: 'post'
      match '/tickets', to: 'tickets#new', via: :get
      match '/checkout', to: 'shows#checkout', via: :get
      match '/checkout', to: 'transactions#checkout', via: :post
      match '/reserve', to: 'tickets#reserve', via: :post
      resources :charge, only: [:create]
      # match '/charge', to: 'charge#new', via: 'get'
    end
    resources :stages
  end
  # get "users/new"
  
  match '/about',   to: 'static_pages#about',   via: 'get'
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
