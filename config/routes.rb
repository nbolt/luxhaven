Luxhaven::Application.routes.draw do

  post '/signup' => 'auth#signup'
  post '/login'  => 'auth#login'
  post '/logout' => 'auth#logout'

  root to: 'home#index'
end
