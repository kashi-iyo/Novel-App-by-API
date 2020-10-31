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
        @tag = UserTag.find_by(id: params[:id])
        check_existing?(@tag, "tag")
    end

end