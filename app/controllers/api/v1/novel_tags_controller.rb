class Api::V1::NovelTagsController < ApplicationController

    before_action :set_tag, only: [:show]

    #Read NovelTagsフィード
    def index
        crud_object(
            object: NovelTag.all,
            data_type: "series_tag",
            crud_type: "index"
        )
            # → Applicationコントローラ
    end

    #Read NovelTagsに関連付けられているNovelSeries
    def show
        crud_object(
            object: @tag,
            data_type: "series_tag",
            crud_type: "show"
        )
            # → Applicationコントローラ
    end

    private

        # パラメータに基づいたシリーズを取得
        def set_tag
            @tag = NovelTag.find_by(id: params[:id])
        end

end