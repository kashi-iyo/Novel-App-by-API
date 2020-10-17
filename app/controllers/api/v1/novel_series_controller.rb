class Api::V1::NovelSeriesController < ApplicationController

    # auth ログインしているかどうかの確認
    before_action :logged_in_user, only: [:create, :edit, :update, :destroy]
    # novels パラメータの基づいたシリーズ取得(@novel_series / @errorsを返す)
    before_action :set_novel_series, only: [:show, :edit, :update, :destroy]
    # novels パラメータに基づいたタグのデータを取得(@novel_tags)
    before_action :set_series_tags, only: [:create, :update]

    # novels NovelSeriesオブジェクト全件をJSONとしてレンダリング
    def index
        series = NovelSeries.all
        @all_series = return_all_series_object(series)    # Applicationコントローラでホームに表示させたいNovelSeriesオブジェクトを取得
        @series_count = @all_series.count   #取得したNovelSeriesオブジェクトの総数
        render json: {
            status: 200,
            series_count: @series_count,
            all_series: @all_series,
            keyword: "index_of_series"
        }
    end

    # novels 1つのNovelSeries／そのNovelSeriesが持つNovels全件をJSONとしてレンダリング
    def show
        # ApplicationControllerでNovelSeriesのオブジェクトを生成し、そのJSONデータをレンダリングする
        create_new_series_object(@novel_series, "one_of_series_data")
    end

    # NovelSeriesを作成
    def create
        @novel_series = current_user.novel_series.new(novel_series_params)
        # 引数に渡されるデータに基づいて、新規のオブジェクトをDBに保存する
        save_new_object_to_db(
            @novel_series,
            @novel_tags,
            "series",
        )
    end

    # NovelSeriesを編集するためのデータを取得
    def edit
        get_edit_object(@novel_series, "series")
    end

    # NovelSeriesを更新
    def update
        # 引数に渡されるデータに基づいて、新規のオブジェクトをDBに保存する
        update_object_to_db(
            @novel_series,
            novel_series_params,
            @novel_tags,
            "series",
        )
    end

    # NovelSeriesを削除
    def destroy
        if authorized?(@novel_series)
            @novel_series.destroy
            render json: { head: :no_content, success: "正常に削除されました。" }
        else
            handle_unauthorized(@novel_series)
        end
    end

    private

        # NovelSeriesオブジェクト作成用のStrong Parameters
        def novel_series_params
            params.require(:novel_series).permit(:series_title, :series_description, :author, :release)
        end

        # tags NovelSeriesオブジェクト作成時に一緒に送られてくるNovelTagのデータを取得
        def set_series_tags
            @novel_tags = params[:novel_series][:novel_tag_name].split(",") unless params[:novel_series][:novel_tag_name].nil?
        end

        # novels パラメータに基づきNovelSeriesオブジェクトを取得
        def set_novel_series
            # validates 欲しいNovelSeriesオブジェクトが存在するかどうかをチェック
            if NovelSeries.find_by(id: params[:id]).nil?
                return_not_present_data()
            else
                @novel_series = NovelSeries.find_by(id: params[:id])
            end
        end

end