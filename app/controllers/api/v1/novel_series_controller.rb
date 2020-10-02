class Api::V1::NovelSeriesController < ApplicationController

    # ログインしているかどうかの確認
    before_action :logged_in_user, only: [:create, :edit, :update, :destroy]
    before_action :set_novel_series, only: [:series_tags, :show, :edit, :update, :destroy]

    def index
        @tags = NovelTag.all
        @all_novel_series = NovelSeries.all
        @all_novel_series.count_in_series(@all_novel_series)    #シリーズの総数
        @series_count = @all_novel_series.count.to_s    #シリーズが持つ小説の総数
        render json: {
            status: 200,
            tags: @tags,
            series_count: @series_count,
            novel_series: @all_novel_series,
            keyword: "index_of_series"
        }
    end

    def series_tags
        @id = @novel_series.id.to_s
        @tags = @novel_series.tags_in_series
        render json: {
            status: 200,
            series_id: @id,
            series_tags: @tags,
            keyword: "series_tags"
        }
    end

    # タグに関連付けられているシリーズ
    def series_in_tag
        @tags = NovelTag.find_by(id: params[:id])
        @series = @tags.novel_series
        render json: {status: 200, series_in_tag: @series, keyword: "series_in_tag"}
    end

    def show
        @novel_in_series = @novel_series.novels.all
        @series_tags = @novel_series.novel_tags
        # 公開時には全員が閲覧可能
        if release?(@novel_series)
            id = @novel_series.id.to_s
            render json: {
                status: 200,
                novel_series: @novel_series,
                novel_in_series: @novel_in_series,
                id: id,
                tags: @series_tags,
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
                tags: @series_tags,
                keyword: "show_of_series"
            }
        else
            handle_unrelease(@novel_series)
        end
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
            handle_unauthorized
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