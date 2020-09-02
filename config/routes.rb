Rails.application.routes.draw do
  
  root 'series#home'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :novel_series, only: [:index, :show, :create, :update, :destroy]
    end
  end

  resources :users, only: [:create, :show, :index]

  post '/login', to: 'sessions#login'
  delete '/logout', to: 'sessions#logout'
  get '/logged_in', to: 'sessions#is_logged_in?'
end
