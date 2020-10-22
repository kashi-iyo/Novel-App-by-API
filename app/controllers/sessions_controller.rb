class SessionsController < ApplicationController

    before_action :logged_in?, only: [:login, :is_logged_in?, :logout]
    before_action :set_user, only: [:login]
    before_action :current_user, only: [:is_logged_in?, :logout]

    def login
        helpers.pass_object_for_sessions(@user, session_params[:password], "login")
    end

    def is_logged_in?
        helpers.pass_object_for_sessions(@current_user.id, {}, "is_logged_in?")
    end

    def logout
        helpers.pass_object_for_sessions({}, {}, "logout")
    end

    private

        def session_params
            params.require(:user).permit(:email, :password)
        end

        def set_user
            @user = User.find_by(email: session_params[:email])
        end

end