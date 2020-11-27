module SessionConcern

    extend ActiveSupport::Concern

    included do
        helper_method :pass_object_for_sessions
    end

    #auth 認証機構
    def pass_object_for_sessions(session_data)
        user = session_data[:object]
        params = session_data[:params]
        action = session_data[:action]
        # ログイン中&ログインユーザーが存在する場合
        if logged_in?
            return logging_case(user: user, action: action)
        # 非ログインの場合
        elsif !logged_in?
            return not_logging_case(user: user, params: params, action: action)
        end
    end

    #auth ログイン中の挙動
    def logging_case(session_data)
        user = session_data[:user]
        action = session_data[:action]
        case action
        #error ログインしているのにログインしようとする
        when "login"
            unauthorized_errors(errors: "すでにログインしています。", error_type: "already_login")
        when "is_logged_in?"
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

    #auth ログインしていない場合の挙動
    def not_logging_case(session_data)
        action = session_data[:action]
        user = session_data[:user]
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
        when "is_logged_in?"
            return_session_data(
                action: action,
                logged_in: false
            )
        #error ログインしてないのにログアウトしようとする場合
        when "logout"
            unauthorized_errors(errors: "不正なアクセスです。")
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