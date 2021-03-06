class Api::V1::NovelFavoritesController < ApplicationController

    # logged_in_user()メソッド：authentication_features_concern.rb内に定義

    before_action :logged_in_user, only: [:create, :destroy]
    before_action :set_novel, only: [:create]
    before_action :set_favorites, only: [:destroy]

    # crud_objecgt()メソッド：application_controller.rb内に定義
    # pass_object_to_crud()メソッド：application_controller.rb内に定義

    #Create お気に入りON
    def create
        crud_object(
            object: current_user.novel_favorites,
            params: favorite_params,
            association_data: @novel,
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

    # check_existing?()メソッド：validates_features_concern.rb内に定義

        # お気に入りのStrong Parameters
        def favorite_params
            params.require(:novel_favorite).permit(:novel_id, :user_id, :favoriter)
        end

        # シリーズが所有する小説1話分を取得
        def set_novel
            @novel = check_existing?(
                object: Novel,
                params: params[:novel_id],
                data_type: "novel")
        end

        def set_favorites
            @novel_favorite = check_existing?(
                object: NovelFavorite,
                params: params[:novel_id],
                params2: params[:id],
                data_type: "favorite")
        end

end