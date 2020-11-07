module AuthenticationFeaturesConcern

    extend ActiveSupport::Concern

# auth 認証系の処理を行うメソッド
    included do
        helper_method :login!, :logged_in?, :logged_in_user, :current_user
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


end