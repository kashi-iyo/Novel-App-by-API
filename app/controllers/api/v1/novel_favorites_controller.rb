class Api::V1::NovelFavoritesController < ApplicationController

    before_action :logged_in_user, only: [:create, :destroy]
    before_action :set_novel
    before_action :set_novel_series, only: [:series_has_favorites]

    # 1つの小説の持つお気に入り数
    def index
        favorites = @novel_in_series.novel_favorites
        favorites = favorites.map do |favorite|
            ["user_id": favorite.user_id, "favoriter": favorite.favoriter]
        end
        favorites_count = @novel_in_series.novel_favorites.count.to_s
        render json: {
            status: 200,
            favorites: favorites.flatten,
            favorites_count: favorites_count
        }
    end

    # お気に入りON
    def create
        # お気に入り済み→エラー／お気に入りしてない→成功
        if @novel_in_series.favorited_by?(current_user)
            render json: {
                status: :unprocessable_entity,
                errors: "すでにお気に入り済みです。"
            }
        else
            @novel_favorite = current_user.novel_favorites.new(favorite_params)
            @novel_favorite.save
            favorites_count = @novel_in_series.novel_favorites.count.to_s
            render json: {
                status: :created,
                favorites_count: favorites_count
            }
        end
    end

    # お気に入りOFF
    def destroy
        @novel_favorite = NovelFavorite.find_by(novel_id: params[:novel_id], user_id: params[:user_id])
        @novel_favorite.destroy
        favorites_count = @novel_in_series.novel_favorites.count.to_s
        render json: {head: :no_content, favorites_count: favorites_count}
    end

    # 小説の総お気に入り数
    def series_has_favorites
        @count = @novel_series.count_favorites(@novel_series)
        render json: {
            status: 200,
            count: @count,
            keyword: "series_has_favorites"
        }
    end

    private

        # お気に入りのStrong Parameters
        def favorite_params
            params.require(:novel_favorite).permit(:novel_id, :user_id, :favoriter)
        end

        # シリーズが所有する小説1話分を取得
        def set_novel
            @novel_in_series = Novel.find_by(id: params[:novel_id])
        end

end