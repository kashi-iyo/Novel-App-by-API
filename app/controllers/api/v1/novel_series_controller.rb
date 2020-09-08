class Api::V1::NovelSeriesController < ApplicationController

    # ログインしているかどうかの確認
    before_action :logged_in_user, only: [:create, :edit, :update, :destroy]
    before_action :set_novel_series, only: [:show, :edit, :update, :destroy]

    def index
        @all_novel_series = NovelSeries.all
        @all_novel_series.map do |series|
            series.user.id === series.user_id ?
            series.author = series.user.nickname :
            null
        end
        render json: { status: 200, novel_series: @all_novel_series }
    end

    def show
        if release_series?
            id = @novel_series.id.to_s
            render json: { status: 200, novel_series: @novel_series, id: id}
        else
            handle_unrelease
        end
    end

    def create
        @novel_series = current_user.novel_series.new(novel_series_params)
        if authorized?
            if @novel_series.save
                series_id = @novel_series.id.to_s
                render json: {
                    status: :created,
                    novel_series: @novel_series,
                    series_id: series_id,
                    location: api_v1_novel_series_path(@novel_series),
                    success_messages: ["正常に保存されました。"]
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
        if authorized?
            render json: { status: 200, novel_series: @novel_series }
        else
            handle_unauthorized
        end
    end

    def update
        if authorized?
            if @novel_series.update(novel_series_params)
                render json: { status: :ok, location: api_v1_novel_series_path(@novel_series), successful: ["編集が完了しました。"] }
            else
                render json: { errors: ["入力内容に誤りがあります。"], status: :unprocessable_entity }
            end
        else
            handle_unauthorized
        end
    end

    def destroy
        if authorized?
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

        # releaseが真かどうか確認
        def release_series?
            !!@novel_series.release
        end

        # 非公開の場合には以下のデータをレンダーする
        def handle_unrelease
            unless release_series?
                render json: { messages:"このシリーズは公開されていません。", status: 400 }
            end
        end

        # シリーズを取得
        def set_novel_series
            @novel_series = NovelSeries.find(params[:id])
            @user_nickname = @novel_series.user.nickname
        end

        # ログイン中のユーザーと、今見ているシリーズの作成者が一致するかをbool値で返す
        def authorized?
            @novel_series.user == current_user
        end

        # シリーズの作者とログインユーザーが不一致な場合の処理
        def handle_unauthorized
            unless authorized?
                render json: { messages: "アクセス権限がありません。", status: 401 }
            end
        end

end