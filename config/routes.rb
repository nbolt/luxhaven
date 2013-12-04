Luxhaven::Application.routes.draw do

  post '/stripe-event' => 'stripe#event'
  post '/enquire' => 'application#enquire'

  post '/forgot' => 'auth#forgot'
  post '/reset' => 'auth#reset'
  get '/check_reset_token' => 'auth#check'
  get '/features' => 'application#features'

  get '/hiring' => 'home#hiring'

  match '/listings/:action' => 'listings', via: [:get, :post]

  get '/region/:region' => 'application#jregion'

  post '/signup'  => 'auth#signup'
  post '/signin'  => 'auth#signin'
  post '/signout' => 'auth#signout'
  post '/auth'    => 'auth#auth'

  get '/account' => 'account#index'
  match '/account/:action' => 'account', via: [:get, :post]

  get '/booking/:booking' => 'booking#index'
  match '/booking/:booking/:action' => 'booking', via: [:get, :post]

  match '/listing_management/:id/:action' => 'listing_management', via: [:get, :post, :patch]

  get   '/:city' => 'listings#search'
  get   '/:city/:listing_slug' => 'listings#show'
  patch '/:city/:listing_slug' => 'listings#update'
  match '/:city/:listing_slug/:action' => 'listings', via: [:get, :post]

  root to: 'home#index'
end
