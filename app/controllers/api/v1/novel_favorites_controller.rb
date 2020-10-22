class Api::V1::NovelFavoritesController < ApplicationController

    before_action :logged_in_user, only: [:create, :destroy]
    before_action :set_novel, only: [:create]
    before_action :set_favorites, only: [:destroy]

    #Create お気に入りON
    def create
        #! お気に入り済み→エラー／お気に入りしてない→成功
        if @novel_in_series.favorited_by?(current_user)
            already_existing_favorites()
        else
            @novel_favorite = current_user.novel_favorites.new(favorite_params)
            helpers.create_and_save_object(
                @novel_favorite,    #object
                {},                 #association_data
                "favorites",        #data_type
            )
        end
    end

    #Destroy お気に入りOFF
    def destroy
        helpers.pass_object_to_crud(@novel_favorite, {}, {}, "favorites", "destroy")
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

        def set_favorites
            @novel_favorite = NovelFavorite.find_by(novel_id: params[:novel_id], user_id: params[:id])
        end

end