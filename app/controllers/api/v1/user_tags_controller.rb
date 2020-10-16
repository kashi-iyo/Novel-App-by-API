class Api::V1::UserTagsController < ApplicationController

    before_action :set_user_tag, only: [:index, :show]

    # 趣味タグフィード
    def index
        tags = UserTag.all
        # 趣味タグ用のデータを生成
        @tags = create_new_object(tags, "user_tag")
        render json: {
            status: 200,
            tags: @tags,
            keyword: "tags_feed"
        }
    end

    # 取得したタグに関連づけられているユーザーを取得
    def show
        users = @tags.users
        @users = create_new_object(users, "user")
        @tags = return_new_tag_data(@tags, "users")
        render json: {
            status: 200,
            tags: @tags,
            count: @users.count,
            users: @users,
            keyword: "users_in_tag"
        }
    end



    private

    def set_user_tag
        @tags = UserTag.find_by(id: params[:id])
    end

end