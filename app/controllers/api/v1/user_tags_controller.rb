class Api::V1::UserTagsController < ApplicationController

    before_action :set_user_tag, only: [:index, :show]

    #Read 趣味タグフィード
    def index
        tags = UserTag.all
        read_object_to_render(tags, {}, "index_of_user_tags")
    end

    # 取得したタグに関連づけられているユーザーを取得
    def show
        users = @tag.users
        read_object_to_render(users, @tag, "show_of_users_in_tag")
    end



    private

    def set_user_tag
        @tag = UserTag.find_by(id: params[:id])
    end

end