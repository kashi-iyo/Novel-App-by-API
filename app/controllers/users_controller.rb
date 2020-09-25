class UsersController < ApplicationController

    def index
        @users = User.all
        if @users
            render json: { users: @users }
        else
            render json: { status: 500, errors: ['ユーザーが存在しません'] }
        end
    end

    def show
        @user = User.find(params[:id])
        @users_series = @user.novel_series.all
        @series_count = @user.novel_series.count.to_s
        if @user
            render json: {
                status: 200,
                user: @user,
                users_series: @users_series,
                series_count: @series_count,
                keyword: "show_of_user"
            }
        else
            render json: { status: 500, errors: ['ユーザーが見つかりません'] }
        end
    end

    def edit

    end

    def update

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
end