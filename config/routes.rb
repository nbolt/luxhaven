Luxhaven::Application.routes.draw do

  post '/signup' => 'auth#signup'
  post '/login'  => 'auth#login'
  post '/logout' => 'auth#logout'

  get '/hiring' => 'home#hiring'

  root to: 'home#index'
end
