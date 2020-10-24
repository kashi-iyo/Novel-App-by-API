module SessionConcern

    extend ActiveSupport::Concern

    included do
        helper_method :pass_object_for_sessions
    end

    #! 認証機構
    def pass_object_for_sessions(user, params, session_type)
        #! ログイン中&ログインユーザーが存在する場合
        if logged_in? && current_user
            case session_type
                #auth ログインしようとした場合
            when "login"
                bad_access("不正なアクセスです。", session_type)
                #auth ログイン状態のチェックをしようとした場合
            when "is_logged_in?"
                return_session_data(user, session_type)
                #auth ログアウト
            when "logout"
                return_session_data({}, session_type)
            end
        #! 非ログインの場合
        else
            case session_type
                #auth ログインしようとした場合
            when "login"
                    #auth パスワードチェック
                if user && user.authenticate(params)
                    login!
                    return_session_data(user, session_type)
                    #error パスワード違いだった場合
                else
                    bad_access("入力された内容に誤りがあります。", session_type)
                end
                #auth ログイン状態のチェックをしようとした場合
            when "is_logged_in?"
                bad_access("ユーザーが存在しません。", session_type)
                #auth ログアウトしようとした場合
            when "logout"
                bad_access("不正なアクセスです。", session_type)
            end
        end
    end

end