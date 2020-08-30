Rails.application.routes.draw do
  
  resources :users, only[:create, :show, :index]

  post '/login', to: 'sessions#login'
  delete '/logout', to: 'sessions#logout'
  get '/logged_in', to: 'sessions#is_logged_in?'
end
