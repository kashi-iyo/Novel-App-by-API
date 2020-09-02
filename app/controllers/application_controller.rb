class ApplicationController < ActionController::Base

    skip_before_action :verify_authenticity_token

    # 認証系======================================================================
    helper_method :login!, :logged_in?, :logged_in_user, :current_user

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
            render json: { messages: "ログインまたは、新規登録を行ってください。", status: 401 }
        end
    end

    # 現在ログインしているユーザーを返す
    def current_user
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
    # =========================================================================
end
