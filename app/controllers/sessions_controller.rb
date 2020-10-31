class SessionsController < ApplicationController

    before_action :logged_in?, only: [:login, :is_logged_in?, :logout]
    before_action :set_user, only: [:login]
    before_action :current_user, only: [:is_logged_in?, :logout]

    def login
        pass_object_for_sessions(
            object: @user,
            params: session_params[:password],
            action: "login"
        )
    end

    def is_logged_in?
        pass_object_for_sessions(
            object: {
                user_id: @current_user.id,
                nickname: @current_user.nickname
            },
            action: "is_logged_in?"
        )
    end

    def logout
        pass_object_for_sessions(
            action: "logout"
        )
    end

    private

        def session_params
            params.require(:user).permit(:email, :password)
        end

        def set_user
            @user = User.find_by(email: session_params[:email])
            check_existing?(@user, "user")
        end

end