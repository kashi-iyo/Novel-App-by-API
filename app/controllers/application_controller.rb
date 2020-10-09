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
        helper_method :authorized?, :handle_unauthorized, :release?, :handle_unrelease, :series_and_novels_id,:count_in_series

        # ログイン中のユーザーと、今見ているシリーズの作成者が一致するかをbool値で返す
        def authorized?(data)
            data.user === current_user
        end

        # シリーズの作者とログインユーザーが不一致な場合の処理
        def handle_unauthorized(data)
            unless authorized?(data)
                render json: { messages: "アクセス権限がありません。", status: 401 }
            end
        end

        # releaseが真かどうか確認
        def release?(data)
            !!data.release
        end

        # 非公開の場合には以下のデータをレンダーする
        def handle_unrelease(data)
            unless release?(data)
                render json: { messages:"現在この作品は非公開となっています。", status: 400, keyword: "unrelease" }
            end
        end

        # シリーズ渡される：シリーズID
        # 小説が渡される：小説ID
        def series_and_novels_id(series, novels)
            @series_id = series.id.to_s
            @novels_id = novels.id.to_s
        end

        # シリーズが所有する小説総数を取得
        def count_in_series(all_series)
            @novels_count = all_series.map{ |series|
                [series.id, series.novels.count.to_s]
            }.to_h
            @novels_count.each do |k, v|
                all_series.each do |series|
                    if series.id === k
                        series["count"] = v
                    end
                end
            end
        end
    #==========================================================================

    # タグ系機能===============================================================


    #==========================================================================
end
