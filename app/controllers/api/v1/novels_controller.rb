class Api::V1::NovelsController < ApplicationController

    # auth ログインしているかどうかの確認
    before_action :logged_in_user, only: [:create, :edit, :update, :destroy]
    # novels Novelを1件取得（@novel_in_series）
    before_action :set_novel, only: [:show, :edit, :update, :destroy]
    # novels NovelSeriesを取得（@novel_series）
    before_action :set_novel_series, only: [:show, :create]

    #Read Novelオブジェクトを1件取得
    def show
        read_object_to_render(@novel_series, @novel_in_series, "Novels#show")
    end


    #Create 引数に渡されるデータに基づいて、新規のオブジェクトをCreate・Saveする
    def create
        helpers.pass_object_to_crud(
            object: current_user.novels,
            params: novel_in_series_params,
            association_data: @novel_series,
            data_type: "novel_for_create",
            crud_type: "create"
        )
    end

    #Edit 引数に渡されるデータに基づいて、Edit用のオブジェクトを返す
    def edit
        helpers.pass_object_to_crud(
            object: @novel_in_series,
            data_type: "novel",
            crud_type: "edit"
        )
    end

    #Update 引数に渡されるデータに基づいて、オブジェクトをUpdateする
    def update
        helpers.pass_object_to_crud(
            object: @novel_in_series,
            params: novel_in_series_params,
            data_type: "novel",
            crud_type: "update"
        )
    end

    #Destroy 引数に渡されるデータに基づいて、オブジェクトをDestroyする
    def destroy
        helpers.pass_object_to_crud(@novel_in_series, {}, {}, "series", "destroy")
    end


    private

        # NovelSeriesが所有するNovels1件を取得
        def set_novel
            # validates データが存在するかどうかをチェック
            if Novel.find_by(id: params[:id]).nil?
                # error エラーのJSONデータをレンダリング
                return_not_present_data()
            else
                @novel_in_series = Novel.find_by(id: params[:id])
            end
        end

        # novels パラメータに基づきNovelSeriesオブジェクトを取得
        def set_novel_series
            # validates 欲しいNovelSeriesオブジェクトが存在するかどうかをチェック
            if NovelSeries.find_by(id: params[:novel_series_id]).nil?
                # error エラーのJSONデータをレンダリング
                return_not_present_data()
            else
                @novel_series = NovelSeries.find_by(id: params[:novel_series_id])
            end
        end

        # 小説のStrong Parameters
        def novel_in_series_params
            params.require(:novel).permit(:novel_title, :novel_description, :novel_content, :release)
        end

end