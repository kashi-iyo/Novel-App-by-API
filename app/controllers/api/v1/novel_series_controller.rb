class Api::V1::NovelSeriesController < ApplicationController

    # auth ログインしているかどうかの確認
    before_action :logged_in_user, only: [:create, :edit, :update, :destroy]
    # novels パラメータの基づいたシリーズ取得(@novel_series / @errorsを返す)
    before_action :set_novel_series, only: [:show, :edit, :update, :destroy]
    # novels パラメータに基づいたタグのデータを取得(@novel_tags)
    before_action :set_series_tags, only: [:create, :update]

    #Read NovelSeriesオブジェクト全件をJSONとしてレンダリング
    def index
        # series = NovelSeries.all
        # read_object_to_render(series, {}, "NovelSeries#index")
        crud_object(
            object: NovelSeries.all,
            data_type: "series",
            crud_type: "index"
        )
    end

    #read 1つのNovelSeries／そのNovelSeriesが持つNovels全件をJSONとしてレンダリング
    def show
        crud_object(
            object: @novel_series,
            data_type: "series",
            crud_type: "show"
        )
    end

    #Create 引数に渡されるデータに基づいて、新規のオブジェクトをCreate・Saveする
    def create
        crud_object(
            object: current_user.novel_series,
            params: novel_series_params,
            association_data: @novel_tags,
            data_type: "series",
            crud_type: "create"
        )
    end

    #Edit 引数に渡されるデータに基づいて、Edit用のオブジェクトを取得する
    def edit
        pass_object_to_crud(
            object: @novel_series,
            association_data: @novel_series.novel_tags,
            data_type: "series",
            crud_type: "edit",
        )
    end

    #Update 引数に渡されるデータに基づいて、オブジェクトをUpdateする
    def update
        pass_object_to_crud(
            object: @novel_series,
            params: novel_series_params,
            association_data: @novel_tags,
            data_type: "series",
            crud_type: "update"
        )
    end

    #Destroy NovelSeriesを削除
    def destroy
        pass_object_to_crud(
            object: @novel_series,
            data_type: "series",
            crud_type: "destroy"
        )
    end

    private

        #! NovelSeriesオブジェクト作成用のStrong Parameters
        def novel_series_params
            params.require(:novel_series).permit(:series_title, :series_description, :author, :release)
        end

        #! NovelSeriesオブジェクト作成時に一緒に送られてくるNovelTagのデータを取得
        def set_series_tags
            @novel_tags = params[:novel_series][:novel_tag_name].split(",") unless params[:novel_series][:novel_tag_name].nil?
        end

        #! パラメータに基づきNovelSeriesオブジェクトを取得
        def set_novel_series
            # validates 欲しいNovelSeriesオブジェクトが存在するかどうかをチェック
            if NovelSeries.find_by(id: params[:id]).nil?
                return_not_present_data()
            else
                @novel_series = NovelSeries.find_by(id: params[:id])
            end
        end

end