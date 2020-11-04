class SessionsController < ApplicationController

    before_action :set_user, only: [:login]
    before_action :current_user, only: [:is_logged_in?]

    def login
        pass_object_for_sessions(
            object: @user,
            params: session_params[:password],
            action: "login"
        )
            # → session_concern.rb
    end

    def is_logged_in?
        render json: {
            logged_in: true,
            user: {
                id: current_user.id,
                nickname: current_user.nickname,
            },
        }
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