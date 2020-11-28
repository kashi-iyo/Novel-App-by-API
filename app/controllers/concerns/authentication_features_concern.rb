module AuthenticationFeaturesConcern

    extend ActiveSupport::Concern

# auth 認証系の処理を行うメソッド
    included do
        helper_method :login!, :logged_in?, :logged_in_user, :current_user, :check_sessions
    end

    # ログインさせる
    def login!(user)
        session[:user_id] = user.id
    end

    # ログインしているかどうかをbool値で返す
    def logged_in?
        !!session[:user_id]
    end

    # ユーザーがログインしていない場合の処理
    def logged_in_user
        unless logged_in?
            return unauthorized_errors(
                errors: "この機能を使用するにはログインまたは、新規登録が必要です。",
                error_type: "not_login"
            )
        end
    end

    # 現在ログインしているユーザーを返す
    def current_user
        @current_user ||= User.find(session[:user_id]) if logged_in?
    end

    # ログインしているかどうかのチェックを行う
    def check_sessions(path)
        case path
        when "/login"
            # ログインしていなければユーザーデータを返す
            if !!logged_in?
                return unauthorized_errors(
                    errors: "すでにログインしています。",
                    error_type: "already_login"
                )
            else
                return @user = User.find_by(email: session_params[:email])
            end
        when "/logout", "/logged_in"
            # ログインしていればログインユーザーを返す
            if !!logged_in?
                return current_user
            else
                case path
                when "/logout"
                    return unauthorized_errors(
                        errors: "不正なアクセスです。",
                        error_type: "logout"
                    )
                when "/logged_in"
                    return return_session_data(
                        action: "logged_in",
                        logged_in: false
                    )
                end
            end
        end
    end


end