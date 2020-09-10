class SessionsController < ApplicationController

    def login
        @user = User.find_by(email: session_params[:email])
        if logged_in? && current_user
            render json: { status: 401, errors: "不正なアクセスです。" }
        else
            if @user && @user.authenticate(session_params[:password])
                login!
                render json: { logged_in: true, user: @user }
            else
                render json: { status: 401, errors: "入力された内容に誤りがあります。" }
            end
        end
    end

    def is_logged_in?
        if logged_in? && current_user
            render json: { logged_in: true, user: @current_user }
        else
            render json: { logged_in: false, message: "ユーザーが存在しません" }
        end
    end

    def logout
        if current_user
            reset_session
            render json: { status: 200, logged_out: true }
        else
            render json: { status: 401, errors: "不正なアクセスです。" }
        end

    end

    private

        def session_params
            params.require(:user).permit(:email, :password)
        end

end