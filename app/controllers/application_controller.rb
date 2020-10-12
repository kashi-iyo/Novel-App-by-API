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
        helper_method :authorized?, :handle_unauthorized, :release?, :handle_unrelease, :series_and_novels_id,:count_in_series, :new_data, :set_novel_series,  :check_data_whether_release

        # ログイン中のユーザーと、今見ているシリーズの作成者が一致するかをbool値で返す
        def authorized?(data)
            # data.user_id === current_user.id
            data[:user_id] === current_user.id
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

        # パラメータに基づいたシリーズを取得
        def set_novel_series
            @novel_series = NovelSeries.find_by(id: params[:novel_series_id])
        end

        # 新たなデータ構造を作成
        # new_series_data()メソッド, NovelSeriesコントローラのshowアクションにて使用
        def new_data(data, bool)
            # シリーズに紐付けられた小説
            novels = Novel.where(novel_series_id: data.id)
                # 小説のカウント
                novels_count = novels.count
                # 小説が獲得しているお気に入り数をカウント
                favorites = novels.map do |novel|
                    ["favorites_count": novel.novel_favorites.count]
                end
                favorites_count = favorites.flatten.sum {|hash| hash[:favorites_count]}
                # 小説が獲得しているコメント数をカウント
                comments = novels.map do |novel|
                    ["comments_count": novel.comments.count]
                end
                comments_count = comments.flatten.sum{|hash| hash[:comments_count]}
            # シリーズに登録されたタグを取得
            series_tags = data.novel_tags.map { |tag|
                ["tag_id": tag.id, "tag_name": tag.novel_tag_name]
            }.flatten
            # trueならシリーズが所有する小説全件も取得
            if !!bool
                return {
                    id: data.id,    # データのID
                    user_id: data.user_id,  # データのユーザーID
                    author: data.author,  # 作者
                    release: data.release,    # 公開か非公開か
                    series_title: data.series_title,   # タイトル
                    series_description: data.series_description,  # あらすじ
                    novels_count: novels_count,     # 小説の数
                    favorites_count: favorites_count,   # お気に入りの総数
                    comments_count: comments_count,     # コメント数
                    tags: series_tags,      # タグ
                    novels: novels  # 小説全件
                }
            elsif !bool
                return {
                    id: data.id,    # データのID
                    user_id: data.user_id,  # データのユーザーID
                    author: data.author,  # 作者
                    release: data.release,    # 公開か非公開か
                    series_title: data.series_title,   # タイトル
                    series_description: data.series_description,  # あらすじ
                    novels_count: novels_count,     # 小説の数
                    favorites_count: favorites_count,   # お気に入りの総数
                    comments_count: comments_count,     # コメント数
                    tags: series_tags,      # タグ
                }
            end
        end

        # データ全件から新たなデータ構造作成
        # NovelSeriesコントローラのindexにて使用
        def new_series_data(data)
            data.map do |value|
                new_data(value, false)
            end
        end

        # 公開されているシリーズだけを取得
        # NovelSeriesコントローラのindex, show
        def check_data_whether_release(data, bool)
            if !!bool                   # trueの場合には1つのデータをチェック
                if !data[:release] && authorized?(data)    # 公開されているか非公開かをチェック
                    data
                elsif !data[:release]
                    return {            # 非公開の場合はエラーを返す
                        status: 400,
                        messages:"現在この作品は非公開となっています。",
                        keyword: "unrelease"
                        }
                end
            elsif !bool             # falseの場合は全件チェック
                data.map do |series|
                    if !!series[:release]
                        series      # 公開されている場合はデータを返す
                    elsif !series[:release]
                        # 非公開な場合は何も返さない
                    end
                end
            end
        end


    #==========================================================================

    # タグ系機能===============================================================


    #==========================================================================
end
