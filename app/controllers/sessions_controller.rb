class SessionsController < ApplicationController

    before_action :set_user, only: [:login]
    before_action :current_user, only: [:is_logged_in?, :logout]

    def login
        pass_object_for_sessions(
            object: @user,
            params: session_params[:password],
            action: "login"
        )
            # → session_concern.rb
    end

    def is_logged_in?
        pass_object_for_sessions(
            object: current_user,
            action: "is_logged_in?"
        )
    end

    def logout
        # pass_object_for_sessions(
        #     object: current_user,
        #     action: "logout"
        # )
        reset_session
        render json: { status: 200, logged_in: false, successful: "正常にログアウト出来ました。" }
    end

    private

        def session_params
            params.require(:user).permit(:email, :password)
        end

        def set_user
            @user = User.find_by(email: session_params[:email])
        end

end