class Api::V1::NovelSeriesController < ApplicationController

    # auth ログインしているかどうかの確認
    before_action :logged_in_user, only: [:create, :edit, :update, :destroy]
    # novels パラメータの基づいたシリーズ取得(@novel_series / @errorsを返す)
    before_action :set_novel_series, only: [:show, :edit, :update, :destroy]
    # novels パラメータに基づいたタグのデータを取得(@novel_tags)
    before_action :set_series_tags, only: [:create, :update]

    #Read NovelSeriesオブジェクト全件をJSONとしてレンダリング
    def index
        series = NovelSeries.all
        read_object_to_render(series, {}, "index_of_series")
    end

    #read 1つのNovelSeries／そのNovelSeriesが持つNovels全件をJSONとしてレンダリング
    def show
        read_object_to_render(@novel_series, {}, "show_of_series")
    end

    #Create 引数に渡されるデータに基づいて、新規のオブジェクトをCreate・Saveする
    def create
        @novel_series = current_user.novel_series.new(novel_series_params)
        helpers.pass_object_to_crud(
            @novel_series,  #object
            {},             #params
            @novel_tags,    #association_data
            "series",       #data_type
            "create"        #crud_type
        )
    end

    #Edit 引数に渡されるデータに基づいて、Edit用のオブジェクトを取得する
    def edit
        helpers.pass_object_to_crud(
            @novel_series,              #object
            {},                         #params
            @novel_series.novel_tags,   #association_data
            "series",                   #data_type
            "edit"                      #crud_type
        )
    end

    #Update 引数に渡されるデータに基づいて、オブジェクトをUpdateする
    def update
        helpers.pass_object_to_crud(
            @novel_series,          #object
            novel_series_params,    #params
            @novel_tags,            #association_data
            "series",               #data_type
            "update"                #crud_type
        )
    end

    #Destroy NovelSeriesを削除
    def destroy
        helpers.pass_object_to_crud(@novel_series, {}, {}, "series", "destroy")
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