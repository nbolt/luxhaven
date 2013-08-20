Luxhaven::Application.routes.draw do

  post '/stripe-event' => 'stripe#event'
  post '/forgot' => 'auth#forgot'
  post '/reset' => 'auth#reset'
  get '/check_reset_token' => 'auth#check'
  match '/listings/:action' => 'listings', via: [:get, :post]

  post '/signup'  => 'auth#signup'
  post '/signin'  => 'auth#signin'
  post '/signout' => 'auth#signout'
  post '/auth'    => 'auth#auth'

  get '/account' => 'account#index'
  match '/account/:action' => 'account', via: [:get, :post]

  get '/booking/:booking' => 'booking#index'
  match '/booking/:booking/:action' => 'booking', via: [:get, :post]

  get   '/:city' => 'listings#search'
  get   '/:city/:listing_slug' => 'listings#show'
  patch '/:city/:listing_slug' => 'listings#update'
  match '/:city/:listing_slug/:action' => 'listings', via: [:get, :post]

  get '/hiring' => 'home#hiring'

  root to: 'home#index'
end
