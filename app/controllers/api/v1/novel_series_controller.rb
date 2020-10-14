class Api::V1::NovelSeriesController < ApplicationController

    # ログインしているかどうかの確認
    before_action :logged_in_user, only: [:create, :edit, :update, :destroy]
    # パラメータの基づいたシリーズ取得
    before_action :set_novel_series, only: [:show, :edit, :update, :destroy]
    # パラメータに基づいたタグのデータを取得
    before_action :set_series_tags, only: [:create, :update]

    # シリーズ全件を取得
    def index
        series = NovelSeries.all
        all_series = all_of_series_data(series)    # ホームに表示させたいシリーズデータを作成
        series_count = all_series.count   #シリーズの総数
        render json: {
            status: 200,
            series_count: series_count,
            all_series: all_series,
            keyword: "index_of_series"
        }
    end

    # 1つのシリーズ／そのシリーズが持つ小説全件を取得
    def show
        series = new_data_of_series(@novel_series, "one_of_series_data")
        render json: {
            status: 200,
            series: series,
            keyword: "show_of_series"
        }
    end

    def create
        # シリーズの作成
        @novel_series = current_user.novel_series.new(novel_series_params)
        if authorized?(@novel_series)
            if @novel_series.save
                # set_series_tagsメソッドに基づきシリーズにタグを登録
                @novel_series.save_tag(@novel_tags)
                # React側でリダイレクトに使うシリーズのID
                series_id = @novel_series.id.to_s
                render json: {
                    status: :created,
                    series_id: series_id,
                    successful: ["正常に保存されました。"],
                    keyword: "create_of_series"
                }
            else
                render json: {
                    errors: @novel_series.errors.full_messages,
                    status: :unprocessable_entity
                }
            end
        else
            handle_unauthorized(@novel_series)
        end
    end

    def edit
        if authorized?(@novel_series)
            # 編集用のタグデータを取得
            @series_tags = @novel_series.series_tags_for_edit
            render json: {
                status: 200,
                novel_series: @novel_series,
                series_tags: @series_tags,
                keyword: "edit_of_series" }
        else
            handle_unauthorized(@novel_series)
        end
    end

    def update
        if authorized?(@novel_series)
            if @novel_series.update(novel_series_params)
                @novel_series.save_tag(@novel_tags)
                @series_id = @novel_series.id.to_s
                render json: {
                    status: :ok,
                    series_id: @series_id,
                    successful: ["編集が完了しました。"],
                    keyword: "update_of_series"
                }
            else
                render json: {
                    errors: ["入力内容に誤りがあります。"], status: :unprocessable_entity
                }
            end
        else
            handle_unauthorized(@novel_series)
        end
    end

    def destroy
        if authorized?(@novel_series)
            @novel_series.destroy
            render json: { head: :no_content, success: "正常に削除されました。" }
        else
            handle_unauthorized(@novel_series)
        end
    end

    private

        # シリーズのStrong Parameters
        def novel_series_params
            params.require(:novel_series).permit(:series_title, :series_description, :author, :release)
        end

        # シリーズ作成時に一緒に送られてくるタグのデータを取得
        def set_series_tags
            @novel_tags = params[:novel_series][:novel_tag_name].split(",") unless params[:novel_series][:novel_tag_name].nil?
        end

        # シリーズを取得
        def set_novel_series
            # データが存在するかどうかをチェック
            if NovelSeries.find_by(id: params[:id]).nil?
                return_not_present_data()
            else
                @novel_series = NovelSeries.find_by(id: params[:id])
            end
        end

end