class Api::V1::UserTagsController < ApplicationController

    before_action :set_user_tag, only: [:show]

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

    def set_user_tag
        if UserTag.find_by(id: params[:id]).nil?
            # error エラーのJSONデータをレンダリング
            return_not_present_data()
        else
            @tag = UserTag.find_by(id: params[:id])
        end
    end

end