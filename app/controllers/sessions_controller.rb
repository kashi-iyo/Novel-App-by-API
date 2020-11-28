class SessionsController < ApplicationController

    before_action :current_user, only: [:is_logged_in?]
    before_action :set_user, only: [:login, :is_logged_in?, :logout]
    # before_action :set_current_user, only: [:is_logged_in?, :logout]

    def login
        run_sessions(
            object: @user,
            params: session_params[:password],
            action: "login"
        )
            # → session_concern.rb
    end

    def is_logged_in?
        run_sessions(
            object: current_user,
            action: "logged_in"
        )
    end

    def logout
        run_sessions(
            object: current_user,
            action: "logout"
        )
    end

    private

        def session_params
            params.require(:user).permit(:email, :password)
        end

        # ユーザーデータの取得
        def set_user
            # ログイン状態のチェック
            check_sessions(request.fullpath)
        end

end