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
        if logged_in? && current_user
            logging_case(user: user, action: action)
        # 非ログインの場合
        else
            not_logging_case(user: user, params: params, action: action)
        end
    end

    #auth ログイン中の挙動
    def logging_case(session_data)
        action = session_data[:action]
        case action
        #error ログインしているのにログインしようとする
        when "login"
            return unauthorized_errors(errors: "すでにログインしています。")
        # ログアウトする
        when "logout"
            return return_session_data(action: action)
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
                return return_session_data(
                    user: {
                        id: user.id,
                        nickname: user.nickname,
                    },
                    action: action
                )
            #error パスワードチェック失敗
            else
                return unauthorized_errors(errors: "入力された内容に誤りがあります。")
            end
        #error ログインしてないのにログアウトしようとする場合
        when "logout"
            return unauthorized_errors(errors: "不正なアクセスです。")
        end
    end

    #auth ユーザーデータをJSONデータで返す
    def return_session_data(session_data)
        user = session_data[:user]
        action = session_data[:action]
        case action
        when "login"
            render json: {
                status: 200,
                logged_in: true,
                successful: "ログインに成功しました。",
                object: user
            }
        when "logout"
            reset_session
            render json: { status: 200, logged_out: true, successful: "ログアウトしました。" }
        end
    end



end