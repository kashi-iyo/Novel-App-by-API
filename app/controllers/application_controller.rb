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
        helper_method :authorized?, :handle_unauthorized, :release?, :handle_unrelease, :series_and_novels_id,:count_in_series, :new_data_of_series, :all_of_series_data,:set_novel_series, :novels_and_count_of_novels, :data_of_favorites_in_novel, :data_of_comments_in_novel, :one_of_novel_data

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
        # 新たなシリーズのデータ構造を作成
        # →all_of_series_data()メソッド, NovelSeriesコントローラのshowアクションにて使用
        def new_data_of_series(series, dataType)
            # シリーズに紐付けられた小説
            novels_and_count_of_novels(series)
                # 小説が獲得しているお気に入り数をカウント
                favorites = @novels.map do |novel|
                    ["favorites_count": novel.novel_favorites.count]
                end
                favorites_count = favorites.flatten.sum {|hash| hash[:favorites_count]}
                # 小説が獲得しているコメント数をカウント
                comments = @novels.map do |novel|
                    ["comments_count": novel.comments.count]
                end
                comments_count = comments.flatten.sum{|hash| hash[:comments_count]}
            # シリーズに登録されたタグを取得
            series_tags = series.novel_tags.map { |tag|
                ["tag_id": tag.id, "tag_name": tag.novel_tag_name]
            }.flatten
            # シリーズ全件取得したい場合
            if dataType === "all_of_series_data"
                return_data_of_series(
                    data,
                    novels_count,
                    favorites_count,
                    comments_count,
                    series_tags,
                    {}
                )
            # シリーズ1件を取得したい場合
            elsif dataType === "one_of_series_data"
                # 公開の場合
                # もしくは非公開でもログインユーザーと同じ場合
                if release?(series)
                    return_data_of_series(
                        series,
                        novels_count,
                        favorites_count,
                        comments_count,
                        series_tags,
                        novels
                    )
                elsif !release?(series)
                    return {
                        messages: "現在この作品は非公開となっています。"
                    }
                end
            end
        end

        # 1件のシリーズが所有する小説のデータ
        # →new_data_of_series(), one_of_novel_data()にて使用
        def novels_and_count_of_novels(series_data)
            # シリーズに紐付けられた小説
            @novels = Novel.where(novel_series_id: series_data.id)
            # 小説全件のカウント
            @novels_count = @novels.count
        end

        # returnするシリーズのデータ構造のフォーマット
        # →new_data()メソッドで使う
        def return_data_of_series(series, nov_count, fav_count, com_count, tags, novels)
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

        # シリーズデータ全件から新たなデータ構造作成
        # NovelSeriesコントローラのindexにて使用
        def all_of_series_data(data)
            data.map do |value|
                # シリーズが公開されている場合
                if !!value[:release]
                    new_data_of_series(value, "all_of_series_data")
                # シリーズが非公開の場合
                elsif !value[:release]
                    []
                end
            end
        end
    # ==============================================================================

    # 小説のデータを取得するメソッド=================================================
        # 新たな小説1件のデータ構造を作成
        # →NovelsControllerのshowアクションにて使用
        def one_of_novel_data(series_data, novel_data)
            # 公開されている場合
            if release?(novel_data)
                # 小説全件(@novels)／小説総数(@novels_count)
                novels_and_count_of_novels(series_data)
                # お気に入りをしたユーザーなどのデータ(@favorites_data)／お気に入り数(@favorites_count)
                data_of_favorites_in_novel(novel_data)
                # コメントをしたユーザーなどのデータ(@comments_data)／コメント数(@comments_count)
                data_of_comments_in_novel(novel_data)
                # 小説1件のデータフォーマットを返す
                return_data_of_novel(series_data, novel_data, @novels_count, @favorites_data, @favorites_count, @comments_data, @comments_count)
            # 非公開の場合
            elsif !release?(novel_data)
                return {
                    messages: "現在この作品は非公開となっています。"
                }
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
                novels_count: @novels_count,
                favorites_data: @favorites_data,
                favorites_count: @favorites_count,
                comments_data: @comments_data,
                comments_count: @comments_count,
            }
        end

        # 小説1件に対するお気に入りデータ
        # →one_of_novel_data()メソッドにて使用
        def data_of_favorites_in_novel(novel)
            # お気に入りしたユーザーなど
            @favorites_data = novel.novel_favorites.map do |favorite|
                {
                    favorites_id: favorite.id,
                    favorites_user_id: favorite.user_id,
                    favorites_novel_id: favorite.novel_id,
                    favoriter: favorite.favoriter,
                }
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

        # データが存在しない場合に返すレスポンス
        def return_not_present_data
            render json: {
                status: 400,
                errors: "作品が存在しないため、アクセスできません。",
                keyword: "not_present"
            }
        end
#====================================================================================
end
