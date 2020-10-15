class Api::V1::NovelsController < ApplicationController

    # ログインしているかどうかの確認
    before_action :logged_in_user, only: [:create, :edit, :update, :destroy]
    # 小説を取得（@novel_in_series）
    before_action :set_novel
    # シリーズ取得（@novel_series）
    before_action :set_novel_series

    # 小説1話分
    def show
        # 1件の小説のデータを取得
        one_of_novel_data(@novel_series, @novel_in_series)
        render json: {
            status: 200,
            novel: @novel,
            keyword: "show_of_novels"
        }
    end


    # 小説1話作成
    def create
        @novel_in_series = @novel_series.novels.new(novel_in_series_params)
        @novel_in_series.user_id = @novel_series.user_id    # ユーザーID
        @novel_in_series.author = @novel_series.author  # 作者
        if authorized?(@novel_in_series)
            if @novel_in_series.save
                series_and_novels_id(@novel_series, @novel_in_series)
                render json: {
                    status: :created,
                    novel_in_series: @novel_in_series,
                    series_id: @series_id,
                    novels_id: @novels_id,
                    successful: ["正常に保存されました。"],
                    keyword: "create_of_novels"
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

    # 小説1話編集
    def edit
        if authorized?(@novel_in_series)
            series_and_novels_id(@novel_series, @novel_in_series)
            render json: {
                status: 200,
                series_id: @series_id,
                novels_id: @novels_id,
                novel_in_series: @novel_in_series,
                keyword: "edit_of_novels"
            }
        else
            handle_unauthorized(@novel_in_series)
        end
    end

    # 小説1話更新
    def update
        if authorized?(@novel_in_series)
            series_and_novels_id(@novel_series, @novel_in_series)
            if @novel_in_series.update(novel_in_series_params)
                render json: {
                    status: :ok,
                    series_id: @series_id,
                    novels_id: @novels_id,
                    successful: ["編集が完了しました。"],
                    keyword: "update_of_novels"
                }
            else
                render json: {
                    errors: ["入力内容に誤りがあります。"],
                    status: :unprocessable_entity
                }
            end
        else
            handle_unauthorized(@novel_in_series)
        end
    end

    # 小説1話削除
    def destroy
        if authorized?(@novel_in_series)
            @novel_in_series.destroy
            render json: { head: :no_content, success: "正常に削除されました。" }
        else
            handle_unauthorized(@novel_in_series)
        end
    end


    private

        # シリーズが所有する小説1話分を取得
        def set_novel
            # データが存在するかどうかをチェック
            if Novel.find_by(id: params[:id]).nil?
                return_not_present_data()
            else
                @novel_in_series = Novel.find_by(id: params[:id])
            end
        end

        # パラメータに基づいたシリーズを取得
        def set_novel_series
            # データが存在するかどうかをチェック
            if NovelSeries.find_by(id: params[:novel_series_id]).nil?
                return_not_present_data()
            else
                @novel_series = NovelSeries.find_by(id: params[:novel_series_id])
            end
        end

        # 小説のStrong Parameters
        def novel_in_series_params
            params.require(:novel).permit( :novel_title, :novel_description, :novel_content, :release)
        end

end