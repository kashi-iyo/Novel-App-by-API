Rails.application.routes.draw do

  root to: 'api/v1/novel_series#index'

  # シリーズ/小説======================================
    namespace :api do
      namespace :v1 do
        # シリーズ
        resources :novel_series, only: [:index, :show, :edit, :create, :update, :destroy] do
          # 小説
          resources :novels, only: [:show, :edit, :create, :update, :destroy]
        end
        # ユーザー
        resources :users, only: [:create, :show, :edit, :update,  :index]
        # コメント
        resources :comments, only: [:create, :destroy]
        # お気に入り
        resources :novel_favorites, only: [:create, :destroy]
      end
    end
  # ===================================================

  # タグ系=============================================
    namespace :api do
      namespace :v1 do
        resources :user_tags, only: [:index, :show]
        resources :novel_tags, only: [:index, :show]
      end
    end
  # ==================================================

  # コメント/お気に入り================================
    # namespace :api do
    #   namespace :v1 do
    #     resources :novels do
    #       # コメント
    #       resources :comments, only: [:create, :destroy]
    #       # お気に入り
    #       resources :novel_favorites, only: [:create, :destroy]
    #     end
    #   end
    # end
    # =================================================

  #ユーザー系====================================
  # resources :users, only: [:create, :show, :edit, :update,  :index]
  #=============================================

  # 認証============================================
  post '/login', to: 'sessions#login'
  delete '/logout', to: 'sessions#logout'
  get '/logged_in', to: 'sessions#is_logged_in?'
  #=================================================
end
