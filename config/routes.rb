Rails.application.routes.draw do

  root to: 'api/v1/novel_series#index'

  namespace :api do
    namespace :v1 do
      # シリーズ
      resources :novel_series, only: [:index, :show, :edit, :create, :update, :destroy] do
        # 小説
        resources :novels, only: [:show, :edit, :create, :update, :destroy]
      end
      # selectタグで並び替えられたデータを取得
      get "selected_series/:selected_params", to: "novel_series#selected_series"
      # ユーザー
      resources :users, only: [:create, :show, :edit, :update,  :index]
      # タグ系
      resources :user_tags, only: [:index, :show]
      resources :novel_tags, only: [:index, :show]
      # シリーズタグで絞り込みされた後にselectで並び替えられたデータを取得
      get "novel_tags/:id/:selected_params", to: "novel_tags#selected_series"
      # フォロー
      resources :relationships, only: [:create, :destroy]
      get "relationships/:id/followings", to: "relationships#followings"
      get "relationships/:id/followers", to: "relationships#followers"
    end
  end


  namespace :api do
    namespace :v1 do
      resources :novels do
        # コメント
        resources :comments, only: [:create, :destroy]
        # お気に入り
        resources :novel_favorites, only: [:create, :destroy]
      end
    end
  end


  # 認証============================================
  post '/login', to: 'sessions#login'
  delete '/logout', to: 'sessions#logout'
  get '/logged_in', to: 'sessions#is_logged_in?'
  #=================================================
end
