class Api::V1::NovelTagsController < ApplicationController

    before_action :set_tag, only: [:show]

    #Read NovelTagsフィード
    def index
        crud_object(
            object: NovelTag.all,
            data_type: "series_tag",
            crud_type: "index"
        )
    end

    #Read NovelTagsに関連付けられているNovelSeries
    def show
        novel_series = @tag.novel_series
        read_object_to_render(novel_series, @tag, "NovelTags#show")
    end

    private

        # パラメータに基づいたシリーズを取得
        def set_tag
            @tag = NovelTag.find_by(id: params[:id])
        end

end