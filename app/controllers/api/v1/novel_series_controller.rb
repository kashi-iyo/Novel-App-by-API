class Api::V1::NovelSeriesController < ApplicationController

    # ログインしているかどうかの確認
    before_action :logged_in_user, only: [:create, :edit, :update, :destroy]
    before_action :set_novel_series, only: [:show, :edit, :update, :destroy]

    def index
        @all_novel_series = NovelSeries.all
        # @all_novel_series.map do |series|
        #     series.user.id === series.user_id ?
        #     series.author = series.user.nickname :
        #     null
        # end
        # @all_novels = Novels.all
        # @series_id = ""
        @all_novels = @all_novel_series.map do |series|
            series.novels
        end
        @novels = @all_novels.flatten
        @novel_id = @novels.map do |novel|
            novel.novel_series_id
        end
        render json: { status: 200,
            novel_series: @all_novel_series,
            novel_id: @novel_id,
            keyword: "index_of_series"
        }
    end

    def show
        @novel_in_series = @novel_series.novels.all
        # 公開時には全員が閲覧可能
        if release?(@novel_series)
            id = @novel_series.id.to_s
            render json: {
                status: 200,
                novel_series: @novel_series,
                novel_in_series: @novel_in_series,
                id: id,
                keyword: "show_of_series"
            }
        # 非公開時には作者だけが閲覧可能
        elsif !release?(@novel_series) && authorized?(@novel_series)
            id = @novel_series.id.to_s
            render json: {
                status: 200,
                novel_series: @novel_series,
                novel_in_series: @novel_in_series,
                id: id,
                keyword: "show_of_series"
            }
        else
            handle_unrelease(@novel_series)
        end
    end

    def create
        @novel_series = current_user.novel_series.new(novel_series_params)
        if authorized?(@novel_series)
            if @novel_series.save
                series_id = @novel_series.id.to_s
                render json: {
                    status: :created,
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
            handle_unauthorized
        end
    end

    def edit
        if authorized?(@novel_series)
            render json: { status: 200, novel_series: @novel_series, keyword: "edit_of_series" }
        else
            handle_unauthorized(@novel_series)
        end
    end

    def update
        if authorized?(@novel_series)
            if @novel_series.update(novel_series_params)
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
            handle_unauthorized
        end
    end

    def destroy
        if authorized?(@novel_series)
            @novel_series.destroy
            render json: { head: :no_content, location: users_path(@current_user) }
        else
            handle_unauthorized
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