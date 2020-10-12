Rails.application.routes.draw do
  
  root to: 'api/v1/novel_series#index'

  namespace :api do
    namespace :v1 do
      resources :novel_series, only: [:index, :show, :edit, :create, :update, :destroy] do
        resources :novels, only: [:index, :show, :edit, :create, :update, :destroy]
        resources :novel_tags, only: [:index]
      end
    end
  end
  # タグに関連付けされたシリーズ
  get '/api/v1/series_in_tag/:id', to: 'api/v1/novel_tags#series_in_tag'
  # タグフィード
  get '/api/v1/series_tags_feed', to: 'api/v1/novel_tags#tags_feed'

  namespace :api do
    namespace :v1 do
      resources :novels do
        # コメント
        resources :comments, only: [:index, :create, :destroy]
        # お気に入り
        resources :novel_favorites, only: [:index, :create, :destroy]
      end
    end
  end
  # 小説全件のお気に入り総数
  get '/api/v1/series_has_favorites/:novel_series_id',
  to: 'api/v1/novel_favorites#series_has_favorites'

  # 小説タグ=====================================
  # シリーズが所有するタグ
  # get '/api/v1/series_tags/:id', to: 'api/v1/novel_series#series_tags'
  # # タグに関連づけられているシリーズ
  # get '/api/v1/series_in_tag/:id', to: 'api/v1/novel_series#series_in_tag'
  # # タグフィード
  # get '/api/v1/series_tags_feed', to: 'api/v1/novel_series#tags_feed'
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
