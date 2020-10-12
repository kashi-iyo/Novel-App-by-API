class Api::V1::NovelTagsController < ApplicationController

    before_action :set_novel_series, only: [:index]

    # 小説のタグフィード
    def tags_feed
        @tags = NovelTag.all
        @tags.tag_has_series_count(@tags)
        render json: {
            status: 200,
            tags: @tags,
            keyword: "tags_feed"}
    end

    # シリーズが所有するタグのデータ
    def index
        @id = @novel_series.id.to_s
        @tags = @novel_series.tags_in_series    #シリーズが所有するタグを取得
        render json: {
            status: 200,
            series_id: @id,
            series_tags: @tags,
            keyword: "series_tags"
        }
    end

    # タグに関連付けられているシリーズ
    def series_in_tag
        @tag = NovelTag.find_by(id: params[:id])  # タグ
        @series = @tag.novel_series # このタグを持つシリーズ
        count_in_series(@series)     # シリーズ内にある小説のカウント
        @series_count = @series.count.to_s  # シリーズのカウント
        render json: {
            status: 200,
            tag: @tag,
            series_count: @series_count,
            series_in_tag: @series,
            keyword: "series_in_tag"
        }
    end

end