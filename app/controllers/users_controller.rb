class UsersController < ApplicationController

    before_action :set_user, only: [:show, :edit, :update]

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
        if @user
            render json: {
                status: 200,
                user: @user,
                users_series: @users_series,
                series_count: @series_count,
                favorite_series: @favorite_series,
                keyword: "show_of_user"
            }
        else
            render json: { status: 500, errors: ['ユーザーが見つかりません'] }
        end
    end

    def edit
        if @user === current_user
            render json: {
                status: 200,
                user: @user,
                keyword: "edit_of_user"
            }
        else
            render json: { status: 401, errors: "不正なアクセスです。" }
        end
    end

    def update
        if @user === current_user
            if @user.update(update_user_params)
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