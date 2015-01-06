Showboarder::Application.routes.draw do
  devise_scope :user do
    get '/auth/stripe_connect/callback', to: 'users/omniauth_callbacks#stripe_connect'
  end
  
  devise_for :users, :path => '/users', :controllers => { :sessions => "users/sessions", :registrations => "users/registrations", :omniauth_callbacks => "users/omniauth_callbacks" }
  root to: 'static_pages#home'

  # devise_scope :user do
  #   match '/auth/stripe_connect/callback' => 'users/omniauth_callbacks#stripe_connect', :as => :auth_callback, via: [:get, :post]
  # end

  match '/about',   to: 'static_pages#about',   via: 'get'
  
  match '/status/:guid'      => 'sales#status',   via: :get,  as: :status
  match '/confirm/:guid'     => 'sales#show',     via: :get,  as: :confirm
  match '/esuggest/:act', to: 'acts#esuggest', via: 'get'
  match '/eretrieve/', to: 'acts#eretrieve', via: 'get'
  match '/ticketrelease/:ticket', to: 'tickets#release', via: :post
  match '/clearcart', to: 'tickets#clear', via: :post

  resources :users, only: [:show] do
    match '/stripe-connect' => 'users#stripe_connect', via: :get
  end

  resources :boards, only: [:create]

  resources :boards, except: [:index, :create], path:'' do
    match '/ticketed'    => 'boards#ticketed',      via: :get
    resources :shows do
      match '/checkin', to: 'shows#checkin', via: :get
      match '/checkinattendee', to: 'shows#checkin_attendee', via: :post
      match '/checkoutattendee', to: 'shows#checkout_attendee', via: :post
      match '/attendees', to: 'shows#attendees', via: :get
      match '/checkout', to: 'shows#checkout', via: :get
      match '/checkout', to: 'sales#checkout', via: :post
      match '/reserve', to: 'tickets#reserve', via: :post
    end
    resources :stages, only: [:create]
  end

  resources :acts, only: [:show]
  
  resources :stripe_events, only: [:create]
end
