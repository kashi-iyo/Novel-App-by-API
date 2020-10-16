class ApplicationController < ActionController::Base

    skip_before_action :verify_authenticity_token

# 認証系===========================================================================
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
# ===============================================================================

# 小説系機能========================================================================
        helper_method :release?, :authorized?, :handle_unauthorized, :set_novel_series,

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
            !!data[:release] || !data[:release] && authorized?(data)
        end

        # パラメータに基づいたシリーズを取得
        def set_novel_series
            @novel_series = NovelSeries.find_by(id: params[:novel_series_id])
        end

    # シリーズのデータを取得するメソッド============================================
        helper_method :make_new_data_of_series, :return_all_of_series_data

        # 新たなシリーズのデータ構造を作成
        # →return_all_of_series_data()メソッド, NovelSeriesコントローラのshowアクションにて使用
        def make_new_data_of_series(series, data_type)
            # シリーズの所有する小説データ(@novels)/小説総数(@novels_count)/登録されているタグ(@series_tags)
            return_novels_and_novels_count_and_tags(series, true)
            # 小説が獲得しているお気に入り数(@favorites_count)/コメント数(@comments_count)をカウント
            return_count_of_favorites_and_comments(@novels)
            # シリーズ全件取得したい場合
            if data_type === "all_of_series_data"
                return_data_of_series(
                    series, @novels_count, @favorites_count, @comments_count, @series_tags, {}
                )
            # シリーズ1件を取得したい場合
            elsif data_type === "one_of_series_data"
                # 公開の場合
                # もしくは非公開でもログインユーザーと同じ場合
                if release?(series)
                    return_data_of_series(
                        series, @novels_count, @favorites_count, @comments_count, @series_tags, @novels
                    )
                elsif !release?(series)
                    return_unrelease_data()
                end
            end
        end

        # 1件のシリーズが所有する小説全件のデータ/小説総数/タグを返す
        # →make_new_data_of_series(), one_of_novel_data()にて使用
        def return_novels_and_novels_count_and_tags(series_data, data_type)
            # シリーズに紐付けられた小説
            @novels = Novel.where(novel_series_id: series_data.id)
            # 小説全件のカウント
            @novels_count = @novels.count
            if !!data_type
                @series_tags = series_data.novel_tags.map { |tag|
                    ["tag_id": tag.id, "tag_name": tag.novel_tag_name]
                }.flatten
            end
        end

        # 小説が獲得したお気に入り数／コメント数を取得
        # →make_new_data_of_series()にて使用
        def return_count_of_favorites_and_comments(novels)
            count = novels.map do |novel|
                [
                    "favorites_count": novel.novel_favorites.count,
                    "comments_count": novel.comments.count
                ]
            end
            @favorites_count = count.flatten.sum {|hash| hash[:favorites_count]}
            @comments_count = count.flatten.sum{|hash| hash[:comments_count]}
        end

        # returnするシリーズのデータ構造のフォーマット
        # →make_new_data_of_series()メソッドで使う
        def return_data_of_series(series, nov_count, fav_count, com_count, tags, novels)
            return  {
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

        # シリーズデータ全件から新たなデータ構造作成
        # NovelSeriesコントローラのindexにて使用
        def return_all_of_series_data(data)
            data.map do |value|
                # シリーズが公開されている場合
                if !!value[:release]
                    # シリーズデータを生成
                    make_new_data_of_series(value, "all_of_series_data")
                # シリーズが非公開の場合
                elsif !value[:release]
                    {}
                end
            end
        end
    # ==============================================================================

    # 小説のデータを取得するメソッド=================================================
        helper_method :one_of_novel_data, :data_of_comments_in_novel

        # 新たな小説1件のデータ構造を作成
        # →NovelsControllerのshowアクションにて使用
        def one_of_novel_data(series_data, novel_data)
            # 公開されている場合
            if release?(novel_data)
                # 小説全件(@novels)／小説総数(@novels_count)
                return_novels_and_novels_count_and_tags(series_data, false)
                # お気に入りをしたユーザーなどのデータ(@favorites_data)／お気に入り数(@favorites_count)
                data_of_favorites_in_novel(novel_data)
                # コメントをしたユーザーなどのデータ(@comments_data)／コメント数(@comments_count)
                data_of_comments_in_novel(novel_data)
                # 小説1件のデータフォーマットを返す
                return_data_of_novel(series_data, novel_data, @novels_count, @favorites_data, @favorites_count, @comments_data, @comments_count)
            # 非公開の場合
            elsif !release?(novel_data)
                # 非公開の場合のデータを返す
                return_unrelease_data()
            end
        end

        # シリーズが所有する小説データ1件のデータフォーマット
        # →one_of_novel_data()メソッドにて使用
        def return_data_of_novel(series_data, novel_data, novels_count, favorites_data, favorites_count, comments_data, comments_count)
            @novel = {}
            @novel = {
                series_id: series_data.id,
                novel_id: novel_data.id,
                user_id: series_data.user_id,
                author: series_data.author,
                release: novel_data.release,
                series_title: series_data.series_title,
                novel_title: novel_data.novel_title,
                novel_description: novel_data.novel_description,
                novel_content: novel_data.novel_content,
                novels_count: novels_count,
                favorites_data: favorites_data,
                favorites_count: favorites_count,
                comments_data: comments_data,
                comments_count: comments_count,
            }
        end

        # 小説1件に対するお気に入りデータ
        # →one_of_novel_data()メソッドにて使用
        def data_of_favorites_in_novel(novel)
            # お気に入りしたユーザーなど
            # もしお気に入りされていない場合は、空の配列を返す
            # これは、React側でfavorites_idによってお気に入りの状態を判別するため
            if novel.novel_favorites === []
                @favorites_data = [
                    favorites_id: "",
                ]
            else
                @favorites_data = novel.novel_favorites.map do |favorite|
                    {
                        favorites_id: favorite.id,
                        favorites_user_id: favorite.user_id,
                        favorites_novel_id: favorite.novel_id,
                        favoriter: favorite.favoriter,
                    }
                end
            end
            # お気に入り数
            @favorites_count = novel.novel_favorites.count
        end

        # 小説1件に対するコメントデータ
        # →one_of_novel_data()メソッドにて使用
        def data_of_comments_in_novel(novel)
            # コメントをしたユーザーなど
            @comments_data = novel.comments.map do |comment|
                {
                    comment_id: comment.id,
                    comment_user_id: comment.user_id,
                    comment_novel_id: comment.novel_id,
                    content: comment.content,
                    commenter: comment.commenter,
                }
            end
            # コメント数
            @comments_count = novel.comments.count
        end
    # ===============================================================================

    # 不正なデータ取得をしてしまった際のレスポンス===================================
        helper_method :return_not_present_data, :return_unrelease_data

        # データが存在しない場合に返すレスポンス
        # → NovelSeriesコントローラ, Novelsコントローラのprivateにて使用
        def return_not_present_data
            # React側へ送信するJSONデータ
            render json: {
                status: 400,
                errors: "作品が存在しないため、アクセスできません。",
                keyword: "not_present"
            }
        end

        # データが非公開の場合に返すレスポンス
        # → make_new_data_of_series(), one_of_novel_data()にて使用
        def return_unrelease_data
            # React側へ送信するJSONデータ
            render json: {
                status: 200,
                messages: "現在この作品は非公開となっています。",
                keyword: "unrelease"
            }
        end
    # ===============================================================================

    # 新たにオブジェクトを生成するメソッド===========================================
        helper_method :create_new_object

        # 新たに作成したオブジェクトを返す
        # → UserTagsコントローラ, NovelTagsコントローラにて使用
        def create_new_object(data, data_type)
            data.map do |d|
                if data_type === "user_tag"
                    # 趣味タグ
                    return_new_tag_data(d, "users")
                elsif data_type ==="series_tag"
                    # シリーズタグ
                    return_new_tag_data(d, "series")
                elsif data_type === "user"
                    # ユーザーデータ
                    return_new_user_data(d)
                end
            end
        end
    # ===============================================================================

    # タグ系機能=====================================================================
        helper_method :return_new_tag_data

        # タグ系の新たなオブジェクトを生成する
        # →create_new_object()にて使用
        def return_new_tag_data(tag, tags_type)
            return {
                tag_id: tag.id,
                tag_name: tags_type === "users" ? tag.user_tag_name : tag.novel_tag_name,
                count: tags_type === "users" ? tag.users.count : tag.novel_series.count,
            }
        end
    # ===============================================================================

    # ユーザー系機能=================================================================
        helper_method :return_new_user_data

        # ユーザーの新たなオブジェクトを生成する
        # →create_new_object()にて使用
        def return_new_user_data(user)
            return {
                user_id: user.id,
                nickname: user.nickname,
                profile: user.profile,
            }
        end

    # ===============================================================================

#====================================================================================
end
