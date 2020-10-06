class UsersController < ApplicationController

    before_action :logged_in_user, only: [:edit, :update]
    before_action :set_user, only: [:show, :edit, :update, :user_has_tags]

    def index
        @users = User.all
        if @users
            render json: { users: @users }
        else
            render json: { status: 500, errors: ['ユーザーが存在しません'] }
        end
    end

    def show
        @users_series = @user.novel_series.all
        @series_count = @user.novel_series.count.to_s
        @favorite_series = @user.user_favorites_series
        @favorite_series_count = @favorite_series.count.to_s
        @user_tags = @user.user_tags
        if @user
            render json: {
                status: 200,
                user: @user,
                user_tags: @user_tags,
                users_series: @users_series,
                series_count: @series_count,
                favorite_series: @favorite_series,
                favorite_series_count: @favorite_series_count,
                keyword: "show_of_user"
            }
        else
            render json: { status: 500, errors: ['ユーザーが見つかりません'] }
        end
    end

    # 取得したタグに関連づけられているユーザーを取得
    def tag_has_users
        @tags = UserTag.find_by(id: params[:id])
        @users = @tags.users
        render json: {
            status: 200,
            tags: @tags,
            users: @users,
            keyword: "tag_has_users"
        }
    end

    # 趣味タグフィード
    def tags_feed
        @tags = UserTag.all
        @tags.tag_has_users_count(@tags) # タグを登録しているユーザー数
        render json: {
            status: 200,
            tags: @tags,
            keyword: "tags_feed"
        }
    end

    def edit
        if @user === current_user
            @tags = @user.edit_user_tags
            render json: {
                status: 200,
                user: @user,
                user_tags: @tags,
                keyword: "edit_of_user"
            }
        else
            render json: { status: 401, errors: "不正なアクセスです。" }
        end
    end

    def update
        if @user === current_user
            @user_tags = params[:user][:user_tag_name].split(",")
            if @user.update(update_user_params)
                @user.save_user_tag(@user_tags)
                @user_id = @user.id.to_s
                render json: {
                    status: :ok,
                    user_id: @user_id,
                    successful: ["編集が完了しました。"],
                    keyword: "update_of_user"
                }
            else
                render json: { errors: ["入力内容に誤りがあります。"], status: :unprocessable_entity }
            end
        else
            render json: { status: 401, errors: "不正なアクセスです。" }
        end
    end

    def create
        @user = User.new(user_params)
        if @user.save
            login!
            render json: { status: :created, user: @user }
        else
            render json: { status: 500, errors: @user.errors.full_messages }
        end
    end

    private

        def user_params
            params.require(:user).permit(:nickname, :account_id, :email, :password, :password_confirmation)
        end

        def update_user_params
            params.require(:user).permit(:nickname, :profile)
        end

        def set_user
            @user = User.find(params[:id])
        end
end