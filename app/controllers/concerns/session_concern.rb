module SessionConcern

    extend ActiveSupport::Concern

    included do
        helper_method :pass_object_for_sessions
    end

    # 認証機構
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

    # ログイン中の挙動
    def logging_case(session_data)
        action = session_data[:action]
        user = session_data[:user]
        case action
        when "login"
            return bad_access(message: "すでにログインしています。", action: action)
        when "is_logged_in?"
            return return_session_data(user: user, action: action)
        when "logout"
            return return_session_data(user: "ログアウトしました。", action: action)
        end
    end

    # ログインしていない場合の挙動
    def not_logging_case(session_data)
        action = session_data[:action]
        user = session_data[:user]
        params = session_data[:params]
        case action
        when "login"
            #auth パスワードチェック
            if user && user.authenticate(params)
                login!
                return return_session_data(user: user, action: action)
            else
                return bad_access(message: "入力された内容に誤りがあります。", action: action)
            end
        when "logout"
            return bad_access(message: "不正なアクセスです。", action: action)
        end
    end

    # ユーザーデータをJSONデータで返す
    def return_session_data(session_data)
        user = session_data[:user]
        action = session_data[:action]
        case action
        when "login"
            render json: { status: 200, logged_in: true, user: user }
        when "logout"
            reset_session
            render json: { status: 200, logged_out: true, user: user }
        when "is_logged_in?"
            render json: { logged_in: true, user: user }
        end
    end



end