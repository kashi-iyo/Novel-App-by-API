class Api::V1::NovelTagsController < ApplicationController

    before_action :set_tag, only: [:show]

    # 小説のタグフィード
    def tags_feed
        tags = NovelTag.all
        # 趣味タグ用のデータを生成
        @tags = create_new_object(tags, "series_tag")
        render json: {
            status: 200,
            tags: @tags,
            keyword: "tags_feed"}
    end

    # タグに関連付けられているシリーズ
    def show
        @series = @tag.novel_series # このタグを持つシリーズ
        @series_in_tag = return_all_of_series_data(@series)    # タグに関連付けされたシリーズデータを作成
        @series_count = @series_in_tag.count   #シリーズの総数
        render json: {
            status: 200,
            tag: @tag,
            series_count: @series_count,
            series_in_tag: @series_in_tag,
            keyword: "series_in_tag"
        }
    end

    private

        # パラメータに基づいたシリーズを取得
        def set_tag
            @tag = NovelTag.find_by(id: params[:id])  # タグ
        end

end