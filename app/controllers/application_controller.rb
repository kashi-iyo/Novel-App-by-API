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
        helper_method :authorized?, :handle_unauthorized, :release?, :handle_unrelease, :series_and_novels_id,:count_in_series, :new_data, :all_of_series_data,:set_novel_series

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
        # →all_of_series()メソッド, NovelSeriesコントローラのshowアクションにて使用
        def new_data(data, dataType)
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
            if dataType === "all_of_series_data"
                return_data_of_hash(
                    data,
                    novels_count,
                    favorites_count,
                    comments_count,
                    series_tags,
                    {}
                )
            elsif dataType === "one_of_series_data"
                if !!data[:release]
                    return_data_of_hash(
                        data,
                        novels_count,
                        favorites_count,
                        comments_count,
                        series_tags,
                        novels
                    )
                elsif !data[:release]
                    return {
                        messages: "現在この作品は非公開となっています。"
                    }
                end
            end
        end

        # returnするデータ構造
        # →new_data()メソッドで使う
        def return_data_of_hash(series, nov_count, fav_count, com_count, tags, novels)
            return {
                id: series.id,    # データのID
                user_id: series.user_id,  # データのユーザーID
                author: series.author,  # 作者
                release: series.release,    # 公開か非公開か
                series_title: series.series_title,   # タイトル
                series_description: series.series_description,  # あらすじ
                novels_count: nov_count,     # 小説の数
                favorites_count: fav_count,   # お気に入りの総数
                comments_count: com_count,     # コメント数
                tags: tags,      # タグ
                novels: novels  # 小説全件
            }
        end

        # データ全件から新たなデータ構造作成
        # NovelSeriesコントローラのindexにて使用
        def all_of_series_data(data)
            data.map do |value|
                # シリーズが公開されている場合
                if !!value[:release]
                    new_data(value, "all_of_series_data")
                # シリーズが非公開の場合
                elsif !value[:release]
                end
            end
        end
end
