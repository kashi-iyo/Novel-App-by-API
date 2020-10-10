class Api::V1::NovelsController < ApplicationController

    # ログインしているかどうかの確認
    before_action :logged_in_user, only: [:create, :edit, :update, :destroy, :favorites, :unfavorites]
    # 小説を取得
    before_action :set_novel, only: [:show, :edit, :update, :destroy, :favorites_status, :favorites, :unfavorites]
    # シリーズ取得
    before_action :set_novel_series


    def index
        @novels_in_series = @novel_series.novels.all
        render json: {
            status: 200,
            novels_in_series: @novels_in_series,
        }
    end

    def show
        # シリーズのタイトルだけ欲しい
        @series_title = @novel_series.series_title
        series_and_novels_id(@novel_series, @novel_in_series)
        # ログインユーザーと小説の作者が一致する場合
        if current_user === @novel_in_series.user
            render json: {
                status: 200,
                novel_in_series: @novel_in_series,
                comments: @novel_in_series.comments,
                novel_id: @novels_id,
                series_title: @series_title,
                series_id: @series_id,
                keyword: "index_of_novels"
            }
        # 公開されている場合
        elsif release?(@novel_in_series)
            render json: {
                status: 200,
                novel_in_series: @novel_in_series,
                series_title: @series_title,
                series_id: @series_id,
                keyword: "index_of_novels"
            }
        else
            handle_unrelease(@novel_in_series)
        end
    end

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

    def destroy
        if authorized?(@novel_in_series)
            @novel_in_series.destroy
            render json: { head: :no_content, success: "正常に削除されました。" }
        else
            handle_unauthorized(@novel_in_series)
        end
    end

    # 1つの小説の持つお気に入り数
    def favorites_status
        favorites = @novel_in_series.novel_favorites
        favorites = favorites.map do |favorite|
            ["user_id": favorite.user_id, "favoriter": favorite.favoriter]
        end
        favorites_count = @novel_in_series.novel_favorites.count.to_s
        render json: {
            status: 200,
            favorites: favorites.flatten,
            favorites_count: favorites_count
        }
    end

    # お気に入りON
    def favorites
        # お気に入り済み→エラー／お気に入りしてない→成功
        if @novel_in_series.favorited_by?(current_user)
            render json: {
                status: :unprocessable_entity,
                errors: "すでにお気に入り済みです。"
            }
        else
            @novel_favorite = current_user.novel_favorites.new(favorite_params)
            @novel_favorite.save
            favorites_count = @novel_in_series.novel_favorites.count.to_s
            render json: {
                status: :created,
                favorites_count: favorites_count
            }
        end
    end

    # お気に入りOFF
    def unfavorites
        @novel_favorite = NovelFavorite.find_by(novel_id: params[:id], user_id: params[:user_id])
        @novel_favorite.destroy
        favorites_count = @novel_in_series.novel_favorites.count.to_s
        render json: {head: :no_content, favorites_count: favorites_count}
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

        # お気に入りのStrong Parameters
        def favorite_params
            params.require(:novel_favorite).permit(:novel_id, :user_id, :favoriter)
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