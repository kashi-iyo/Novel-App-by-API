class Api::V1::UserTagsController < ApplicationController

    before_action :set_user_tag, only: [:show]

    # crud_objecgt()メソッド：application_controller.rb内に定義

    #Read 趣味タグフィード
    def index
        crud_object(
            object: UserTag.all,
            data_type: "user_tag",
            crud_type: "index"
        )
    end

    # 取得したタグに関連づけられているユーザーを取得
    def show
        crud_object(
            object: @tag,
            data_type: "user_tag",
            crud_type: "show"
        )
    end



    private

    # check_existing?()メソッド：validates_features_concern.rb内に定義

        def set_user_tag
            @tag = check_existing?(
                object: UserTag,
                params: params[:id],
                data_type: "tag")
        end

end