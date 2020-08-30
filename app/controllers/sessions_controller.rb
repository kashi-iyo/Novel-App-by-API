class SessionsController < ApplicationController

    def login
        @user = User.find_by(email: session_params[:email])

        if @user && @user.authenticate(session_params[:password])
            login!
            render json: { logged_in: true, user: @user }
        else
            render json: { status: 401, errors: ["入力された内容に誤りがあります。"] }
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
        reset_session
        render json: { status: 200, logged_out: true }
    end

    private

        def session_params
            params.require(:user).permit(:email, :password)
        end

end