class Api::V1::NovelFavoritesController < ApplicationController

    before_action :logged_in_user, only: [:create, :destroy]
    before_action :set_novel, only: [:create]
    before_action :set_favorites, only: [:destroy]

    #Create お気に入りON
    def create
        crud_object(
            object: current_user.novel_favorites,
            params: favorite_params,
            association_data: @novel_in_series,
            data_type: "favorites",
            crud_type: "create"
        )
            # → application_controller.rb
    end

    #Destroy お気に入りOFF
    def destroy
        pass_object_to_crud(
            object: @novel_favorite,
            data_type: "favorites",
            crud_type: "destroy"
        )
            # → application_controller.rb
    end

    private

        # お気に入りのStrong Parameters
        def favorite_params
            params.require(:novel_favorite).permit(:novel_id, :user_id, :favoriter)
        end

        # シリーズが所有する小説1話分を取得
        def set_novel
            @novel_in_series = Novel.find_by(id: params[:novel_id])
            check_existing?(@novel_in_series, "novel")
                # → validates_features_concern.rb
        end

        def set_favorites
            @novel_favorite = NovelFavorite.find_by(novel_id: params[:novel_id], user_id: params[:id])
            check_existing?(@novel_favorite, "favorite")
                # → validates_features_concern.rb
        end

end