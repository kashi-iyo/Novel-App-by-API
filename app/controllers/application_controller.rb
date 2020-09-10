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

    # 小説系機能===============================================================
        helper_method :authorized?, :handle_unauthorized, :release?, :handle_unrelease

        # ログイン中のユーザーと、今見ているシリーズの作成者が一致するかをbool値で返す
        def authorized?(data)
            data.user === current_user
        end

        # シリーズの作者とログインユーザーが不一致な場合の処理
        def handle_unauthorized
            unless authorized?
                render json: { messages: "不正なアクセスです。", status: 401 }
            end
        end

        # releaseが真かどうか確認
        def release?(data)
            !!data.release
        end

        # 非公開の場合には以下のデータをレンダーする
        def handle_unrelease(data)
            unless release?(data)
                render json: { messages:"非公開中。", status: 400 }
            end
        end
    #==========================================================================
end
