module AuthenticationFeaturesConcern

    extend ActiveSupport::Concern

# auth 認証系の処理を行うメソッド
    included do
        helper_method :login!, :logged_in?, :logged_in_user, :current_user
    end

    # ログインさせる
    def login!
        session[:user_id] = @user.id
    end

    # ログインしているかどうかをbool値で返す
    def logged_in?
        !!session[:user_id]
    end

    # ユーザーがログインしていない場合の処理
    def logged_in_user
        unless logged_in?
            render json: {
                status: :unauthorized,
                messages: "ログインまたは、新規登録を行ってください。",
            }
        end
    end

    # 現在ログインしているユーザーを返す
    def current_user
        if session[:user_id]
            @current_user ||= User.find(session[:user_id])
        else
            return bad_access(message: "ログインまたは、新規登録を行ってください。", action: "current_user")
        end
    end


end