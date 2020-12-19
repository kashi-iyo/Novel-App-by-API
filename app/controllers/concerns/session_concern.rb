module SessionConcern

    extend ActiveSupport::Concern

    included do
        helper_method :run_sessions, :return_session_data
    end

    # ログイン/ログイン保持チェック/ログアウトを実行
    # return_session_data()：以下で定義
    def run_sessions(session_data)
        action = session_data[:action]
        user = session_data[:object]
        params = session_data[:params]
        case action
        when "login"
            # パスワードチェック
            if user && user.authenticate(params)
                login!(user)
                return_session_data(
                    action: action,
                    logged_in: true,
                    successful: "正常にログイン出来ました。",
                    user: { id: user.id, nickname: user.nickname }
                )
            #error パスワードチェック失敗
            else
                unauthorized_errors(errors: "メールアドレス、もしくはパスワードが間違っています。再度入力をし直してください。", error_type: "authenticate_password")
            end
        when "logged_in"
            return_session_data(
                action: action,
                logged_in: true,
                user: {id: user.id, nickname: user.nickname}
            )
        # ログアウトする
        when "logout"
            reset_session
            return_session_data(
                action: action,
                logged_in: false,
                successful: "正常にログアウト出来ました。"
            )
        end
    end

    #auth ユーザーデータをJSONデータで返す
    def return_session_data(session_data)
        render json: {
            status: 200,
            action: session_data[:action],
            logged_in: session_data[:logged_in],
            successful: session_data[:successful],
            object: session_data[:user]
        }
    end

end