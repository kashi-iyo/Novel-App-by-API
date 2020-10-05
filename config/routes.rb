Rails.application.routes.draw do
  
  root to: 'api/v1/novel_series#index'

  namespace :api do
    namespace :v1 do
      resources :novel_series, only: [:index, :show, :edit, :create, :update, :destroy] do
        resources :novels, only: [:index, :show, :edit, :create, :update, :destroy]
      end
    end
  end

  # お気に入り
  get '/api/v1/novel_favorites/:id', to: 'api/v1/novels#favorites_status'
  post '/api/v1/novel_favorites/:id', to: 'api/v1/novels#favorites'
  delete '/api/v1/novel_favorites/:id', to: 'api/v1/novels#unfavorites'
  # タグ
  get '/api/v1/series_tags/:id', to: 'api/v1/novel_series#series_tags'
  get '/api/v1/series_in_tag/:id', to: 'api/v1/novel_series#series_in_tag'

  resources :users, only: [:create, :show, :edit, :update,  :index]
  # そのタグを持つユーザー
  get '/tag_has_users/:id', to: 'users#tag_has_users'
  get '/tags_feed', to: 'users#tags_feed'

  post '/login', to: 'sessions#login'
  delete '/logout', to: 'sessions#logout'
  get '/logged_in', to: 'sessions#is_logged_in?'
end
