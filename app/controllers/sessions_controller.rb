class SessionsController < ApplicationController

    before_action :set_user, only: [:login, :logout, :is_logged_in?]

    # run_sessions()：session_concern.rb内に定義

    def login
        run_sessions(
            object: @user,
            params: session_params[:password],
            action: "login"
        )
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

    # check_sessions()：authentication_features_concern.rb内に定義

        def session_params
            params.require(:user).permit(:email, :password)
        end

        # ユーザーデータの取得
        def set_user
            # ログイン状態のチェック
            check_sessions(request.fullpath)
        end

end