class Api::V1::NovelTagsController < ApplicationController

    before_action :set_tag, only: [:show, :selected_series]

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

    def selected_series
        crud_object(
            object: @tag,
            selection: params[:selected_params],
            data_type: "series_tag",
            crud_type: "selected"
        )
    end

    private

        # パラメータに基づいたタグを取得
        def set_tag
            @tag = check_existing?(
                object: NovelTag,
                params: params[:id],
                data_type: "tag")
                # → validates_features_concern.rb
        end

end