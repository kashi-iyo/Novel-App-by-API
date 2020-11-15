class Api::V1::NovelSeriesController < ApplicationController

    # auth ログインしているかどうかの確認
    before_action :logged_in_user, only: [:create, :edit, :update, :destroy]
    # novels パラメータの基づいたシリーズ取得(@novel_series / @errorsを返す)
    before_action :set_series, only: [:show, :edit, :update, :destroy]
    # 公開・非公開のチェック
    before_action :check_release, only: [:show]
    # novels パラメータに基づいたタグのデータを取得(@novel_tags)
    before_action :set_series_tags, only: [:create, :update]

    #Read NovelSeriesオブジェクト全件をJSONとしてレンダリング
    def index
        crud_object(
            object: NovelSeries.all.desc_order,
            data_type: "series",
            crud_type: "index"
        )
    end

    #read 1つのNovelSeries／そのNovelSeriesが持つNovels全件をJSONとしてレンダリング
    def show
        crud_object(
            object: @series,
            data_type: "series",
            crud_type: "show"
        )
    end

    #Create 引数に渡されるデータに基づいて、新規のオブジェクトをCreate・Saveする
    def create
        crud_object(
            object: current_user.novel_series,
            params: series_params,
            association_data: @novel_tags,
            data_type: "series",
            crud_type: "create"
        )
    end

    #Edit 引数に渡されるデータに基づいて、Edit用のオブジェクトを取得する
    def edit
        pass_object_to_crud(
            object: @series,
            association_data: @series.novel_tags,
            data_type: "series",
            crud_type: "edit",
        )
    end

    #Update 引数に渡されるデータに基づいて、オブジェクトをUpdateする
    def update
        pass_object_to_crud(
            object: @series,
            params: series_params,
            association_data: @novel_tags,
            data_type: "series",
            crud_type: "update"
        )
    end

    #Destroy NovelSeriesを削除
    def destroy
        pass_object_to_crud(
            object: @series,
            data_type: "series",
            crud_type: "destroy"
        )
    end

    # selectタグで並び替え
    def selected_series
        selection = params[:selected_params]
        crud_object(
            object: NovelSeries.all,
            selection: selection,
            data_type: "series",
            crud_type: "selected"
        )
    end

    private

        #! NovelSeriesオブジェクト作成用のStrong Parameters
        def series_params
            params.require(:novel_series).permit(:series_title, :series_description, :author, :release)
        end

        #! NovelSeriesオブジェクト作成時に一緒に送られてくるNovelTagのデータを取得
        def set_series_tags
            @novel_tags = params[:novel_series][:novel_tag_name].split(",")
        end

        #! パラメータに基づきNovelSeriesオブジェクトを取得
        def set_series
            @series = check_existing?(
                object: NovelSeries,
                params: params[:id],
                data_type: "series")
                # → validates_features_concern.rb
        end

        # 公開されているか非公開かをチェック
        def check_release
            @series = release?({
                object: @series,
                data_type: "series"
            })
        end

end