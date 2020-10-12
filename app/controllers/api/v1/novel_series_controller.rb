class Api::V1::NovelSeriesController < ApplicationController

    # ログインしているかどうかの確認
    before_action :logged_in_user, only: [:create, :edit, :update, :destroy]
    # パラメータの基づいたシリーズ取得
    before_action :set_novel_series, only: [:show, :edit, :update, :destroy]

    def index
        series = NovelSeries.all
        all_series = new_series_data(series)    # ホームに表示させたいシリーズデータを作成
        @all_series = check_data_whether_release(all_series, false)  # 公開しているシリーズのみを取得
        @series_count = @all_series.count   #シリーズの総数
        render json: {
            status: 200,
            series_count: @series_count,
            all_series: @all_series,
            keyword: "index_of_series"
        }
    end

    def show
        series = new_data(@novel_series, true)
        @series = check_data_whether_release(series, true)
        render json: {
            status: 200,
            series: @series,
            keyword: "show_of_series"
        }
    end

    def create
        @novel_series = current_user.novel_series.new(novel_series_params)
        @novel_tags = params[:novel_series][:novel_tag_name].split(",")
        if authorized?(@novel_series)
            if @novel_series.save
                @novel_series.save_tag(@novel_tags)
                series_id = @novel_series.id.to_s
                render json: {
                    status: :created,
                    novel_tags: @novel_tags,
                    novel_series: @novel_series,
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
            @series_tags = @novel_series.edit_tags
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
        @novel_tags = params[:novel_series][:novel_tag_name].split(",")
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
                render json: { errors: ["入力内容に誤りがあります。"], status: :unprocessable_entity }
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

        # シリーズを取得
        def set_novel_series
            @novel_series = NovelSeries.find(params[:id])
        end

end