Rails.application.routes.draw do
  
  root to: 'api/v1/novel_series#index'

  namespace :api do
    namespace :v1 do
      resources :novel_series, only: [:index, :show, :edit, :create, :update, :destroy] do
        resources :novels, only: [:index, :show, :edit, :create, :update, :destroy]
      end
    end
  end
  get 'api/v1/novel_count/:id', to: 'api/v1/novel_series#novel_count'
  get '/tags_in_series/:id', to: 'api/v1/novel_series#tags_in_series'

  resources :users, only: [:create, :show, :edit, :update,  :index]
  post '/login', to: 'sessions#login'
  delete '/logout', to: 'sessions#logout'
  get '/logged_in', to: 'sessions#is_logged_in?'
end
