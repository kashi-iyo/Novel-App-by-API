module AuthenticationFeaturesConcern

    extend ActiveSupport::Concern

# auth 認証系の処理を行うメソッド
    included do
        helper_method :login!, :logged_in?, :logged_in_user, :current_user, :return_session_data
    end

    #! /// ログインさせる
    def login!
        session[:user_id] = @user.id
    end

    #! /// ログインしているかどうかをbool値で返す
    def logged_in?
        !!session[:user_id]
    end

    #! /// ユーザーがログインしていない場合の処理
    def logged_in_user
        unless logged_in?
            render json: {
                status: :unauthorized,
                messages: "ログインまたは、新規登録を行ってください。",
            }
        end
    end

    #! /// 現在ログインしているユーザーを返す
    def current_user
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end

    #! ユーザーデータを返す
    def return_session_data(user_data, session_type)
        if session_type === "logout"
            reset_session
            render json: { status: 200, logged_out: true }
        else
            render json: { logged_in: true, user: user_data }
        end
    end

end