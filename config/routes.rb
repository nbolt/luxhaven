Luxhaven::Application.routes.draw do

  post '/stripe-event' => 'stripe#event'

  post '/signup'  => 'auth#signup'
  post '/signin'  => 'auth#signin'
  post '/signout' => 'auth#signout'
  post '/auth'    => 'auth#auth'

  get '/:city' => 'listings#search'
  get '/:city/:listing_title' => 'listings#show'
  match '/:city/:listing_title/:action' => 'listings', via: [:get, :post]

  get '/hiring' => 'home#hiring'

  root to: 'home#index'
end
