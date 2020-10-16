Rails.application.routes.draw do

  root to: 'api/v1/novel_series#index'

  # シリーズ/小説======================================
    namespace :api do
      namespace :v1 do
        resources :novel_series, only: [:index, :show, :edit, :create, :update, :destroy] do
          resources :novels, only: [:show, :edit, :create, :update, :destroy]
        end
        resources :novel_tags, only: [:show]
      end
    end
  # ===================================================

  # タグ系=============================================
    namespace :api do
      namespace :v1 do
        resources :user_tags, only: [:index, :show]
      end
    end
    # シリーズタグフィード
    get '/api/v1/series_tags_feed', to: 'api/v1/novel_tags#tags_feed'
  # ==================================================

  # コメント/お気に入り================================
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
    # =================================================

  #ユーザー系====================================
  resources :users, only: [:create, :show, :edit, :update,  :index]
  #=============================================

  # 認証============================================
  post '/login', to: 'sessions#login'
  delete '/logout', to: 'sessions#logout'
  get '/logged_in', to: 'sessions#is_logged_in?'
  #=================================================
end
