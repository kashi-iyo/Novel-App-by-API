class Api::V1::NovelTagsController < ApplicationController

    before_action :set_tag, only: [:show, :selected_series]

    # crud_objecgt()メソッド：application_controller.rb内に定義

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
        crud_object(
            object: @tag,
            data_type: "series_tag",
            crud_type: "show"
        )
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

    # check_existing?()メソッド：validates_features_concern.rb内に定義

        # パラメータに基づいたタグを取得
        def set_tag
            @tag = check_existing?(
                object: NovelTag,
                params: params[:id],
                data_type: "tag")
                # → validates_features_concern.rb
        end

end