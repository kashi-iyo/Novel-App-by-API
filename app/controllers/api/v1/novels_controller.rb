class Api::V1::NovelsController < ApplicationController

    # ログインしているかどうかの確認
    before_action :logged_in_user, only: [:create, :edit, :update, :destroy]
    before_action :set_novel, only: [:show, :edit, :update, :destroy]
    before_action :set_novel_series

    def index
        @novels_in_series = @novel_series.novels.all
        render json: { status: 200, novels_in_series: @novels_in_series }
    end

    def show
        if current_user.id === @novel_in_series.user_id
            @novel_id = @novel_in_series.id.to_s
            render json: {
                status: 200,
                novel_in_series: @novel_in_series,
                novel_series: @novel_series,
                novel_id: @novel_id,
                keyword: "novels"
            }
        elsif release?(@novel_in_series)
            render json: { status: 200, novel_series: @novel_in_series, keyword: "novels"}
        else
            handle_unrelease
        end
    end

    def create
        @novel_in_series = @novel_series.novels.new(novel_in_series_params)
        @novel_in_series.user_id = @novel_series.user_id    # ユーザーID
        @novel_in_series.author = @novel_series.author  # 作者
        @series_id = @novel_series.id.to_s  #シリーズのIDを文字列で取得（Reactでページ遷移に使用する）
        if authorized?(@novel_in_series)
            if @novel_in_series.save
                @novels_id = @novel_in_series.id.to_s   #小説のIDで取得（Reactでページ遷移に使用する）
                render json: {
                    status: :created,
                    novel_in_series: @novel_in_series,
                    series_id: @series_id,
                    novels_id: @novels_id,
                    success_messages: ["正常に保存されました。"]
                }
            else
                render json: {
                    errors: @novel_in_series.errors.full_messages,
                    status: :unprocessable_entity
                }
            end
        else
            handle_unauthorized
        end
    end

    def edit
        if authorized?(@novel_in_series)
            render json: { status: 200, novel_in_series: @novel_in_series, keyword: "novels" }
        else
            handle_unauthorized
        end
    end

    def update
        if authorized?(@novel_in_series)
            if @novel_in_series.update(novel_in_series_params)
                render json: {
                    status: :ok,
                    location: api_v1_novel_series_novel_path(@novel_series, @novel_in_series),
                    successful: ["編集が完了しました。"]
                }
            else
                render json: { errors: ["入力内容に誤りがあります。"], status: :unprocessable_entity }
            end
        else
            handle_unauthorized
        end
    end

    def destroy
        if authorized?(@novel_in_series)
            @novel_in_series.destroy
            render json: { head: :no_content, location: users_path(@current_user) }
        else
            handle_unauthorized
        end
    end

    private

        # 小説を取得
        def set_novel
            @novel_in_series = Novel.find_by(id: params[:id])
        end
        # シリーズを取得
        def set_novel_series
            @novel_series = NovelSeries.find_by(id: params[:novel_series_id])
        end

        # 小説のStrong Parameters
        def novel_in_series_params
            params.require(:novel).permit(
                :novel_title,
                :novel_description,
                :novel_content,
                :release)
        end

end