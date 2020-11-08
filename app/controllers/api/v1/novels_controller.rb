class Api::V1::NovelsController < ApplicationController

    # auth ログインしているかどうかの確認
    before_action :logged_in_user, only: [:create, :edit, :update, :destroy]
    # novels Novelを1件取得（@novel）
    before_action :set_novel, only: [:show, :edit, :update, :destroy]
    # novels NovelSeriesを取得（@series）
    before_action :set_series, only: [:create]

    #Read Novelオブジェクトを1件取得
    def show
        crud_object(
            object: @novel,
            data_type: "novel",
            crud_type: "show"
        )
            # → application_controller.rb
    end


    #Create 引数に渡されるデータに基づいて、新規のオブジェクトをCreate・Saveする
    def create
        pass_object_to_crud(
            object: current_user.novels,
            params: novel_params,
            association_data: @series,
            data_type: "novel_for_create",
            crud_type: "create"
        )
    end

    #Edit 引数に渡されるデータに基づいて、Edit用のオブジェクトを返す
    def edit
        pass_object_to_crud(
            object: @novel,
            data_type: "novel",
            crud_type: "edit"
        )
    end

    #Update 引数に渡されるデータに基づいて、オブジェクトをUpdateする
    def update
        pass_object_to_crud(
            object: @novel,
            params: novel_params,
            data_type: "novel",
            crud_type: "update"
        )
    end

    #Destroy 引数に渡されるデータに基づいて、オブジェクトをDestroyする
    def destroy
        pass_object_to_crud(
            object: @novel,
            data_type: "series",
            crud_type: "destroy"
        )
    end


    private

        # NovelSeriesが所有するNovels1件を取得
        def set_novel
            @novel = check_existing?(
                object: Novel,
                params: params[:id],
                data_type: "novel")
                # → validates_features_concern.rb
        end

        # novels パラメータに基づきNovelSeriesオブジェクトを取得
        def set_series
            @series = check_existing?(
                object: NovelSeries,
                params: params[:novel_series_id],
                data_type: "series")
                # → validates_features_concern.rb
        end

        # 小説のStrong Parameters
        def novel_params
            params.require(:novel).permit(:novel_title, :novel_description, :novel_content, :release)
        end

end