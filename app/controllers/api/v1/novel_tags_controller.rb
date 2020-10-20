class Api::V1::NovelTagsController < ApplicationController

    before_action :set_tag, only: [:show]

    #Read NovelTagsフィード
    def index
        tags = NovelTag.all
        read_object_to_render(tags, {}, "NovelTags#index")
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