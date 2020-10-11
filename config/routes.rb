Rails.application.routes.draw do
  
  root to: 'api/v1/novel_series#index'

  namespace :api do
    namespace :v1 do
      resources :novel_series, only: [:index, :show, :edit, :create, :update, :destroy] do
        resources :novels, only: [:index, :show, :edit, :create, :update, :destroy]
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :novels do
        resources :comments, only: [:index, :create, :destroy]
      end
    end
  end

  # お気に入り==========================
  # 小説全件のお気に入り総数
  get '/api/v1/series_has_favorites/:id', to: 'api/v1/novel_series#series_has_favorites'
  # 小説のお気に入りの数
  get '/api/v1/novel_favorites/:id', to: 'api/v1/novels#favorites_status'
  # 小説をお気に入りする
  post '/api/v1/novel_favorites/:id', to: 'api/v1/novels#favorites'
  # 小説のお気に入りを解除する
  delete '/api/v1/novel_favorites/:id/:user_id', to: 'api/v1/novels#unfavorites'
  #======================================

  # 小説タグ=====================================
  # シリーズが所有するタグ
  get '/api/v1/series_tags/:id', to: 'api/v1/novel_series#series_tags'
  # タグに関連づけられているシリーズ
  get '/api/v1/series_in_tag/:id', to: 'api/v1/novel_series#series_in_tag'
  # タグフィード
  get '/api/v1/series_tags_feed', to: 'api/v1/novel_series#tags_feed'
  #==========================================

  #ユーザー系====================================
  resources :users, only: [:create, :show, :edit, :update,  :index]
  # そのタグを持つユーザー
  get '/tag_has_users/:id', to: 'users#tag_has_users'
  # 趣味タグフィード
  get '/tags_feed', to: 'users#tags_feed'
  #=============================================

  # 認証============================================
  post '/login', to: 'sessions#login'
  delete '/logout', to: 'sessions#logout'
  get '/logged_in', to: 'sessions#is_logged_in?'
  #=================================================
end
