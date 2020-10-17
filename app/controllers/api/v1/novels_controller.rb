class Api::V1::NovelsController < ApplicationController

    # auth ログインしているかどうかの確認
    before_action :logged_in_user, only: [:create, :edit, :update, :destroy]
    # novels Novelを1件取得（@novel_in_series）
    before_action :set_novel, only: [:show, :edit, :update]
    # novels NovelSeriesを取得（@novel_series）
    before_action :set_novel_series, only: [:show, :create]

    # novels Novelオブジェクトを1件取得
    def show
        # Applicationコントローラで生成した1件のNovelオブジェクトをJSONとしてレンダリング
        create_new_novel_object(@novel_series, @novel_in_series)
    end


    # novels Novelを1件作成
    def create
        @novel = @novel_series.novels.new(novel_in_series_params)
        # 引数に渡されるデータに基づいて、新規のオブジェクトをDBに保存する
        save_new_object_to_db(
            @novel,
            @novel_series,
            "novel",
        )
    end

    # 小説1話編集
    def edit
        get_edit_object(@novel_in_series, "novel")
    end

    # 小説1話更新
    def update
        update_object_to_db(
            @novel_in_series,
            novel_in_series_params,
            {},
            "novel",
        )
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