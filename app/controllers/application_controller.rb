class ApplicationController < ActionController::Base

    skip_before_action :verify_authenticity_token

# auth 認証系==================================================================================
        helper_method :login!, :logged_in?, :logged_in_user, :current_user

        # /// ログインさせる
        def login!
            session[:user_id] = @user.id
        end

        # /// ログインしているかどうかをbool値で返す
        def logged_in?
            !!session[:user_id]
        end

        # /// ユーザーがログインしていない場合の処理
        def logged_in_user
            unless logged_in?
                render json: { messages: "ログインまたは、新規登録を行ってください。", status: 401 }
            end
        end

        # /// 現在ログインしているユーザーを返す
        def current_user
            @current_user ||= User.find(session[:user_id]) if session[:user_id]
        end
# auth ========================================================================================

# validates 認可用メソッド=====================================================================
    helper_method :release?, :authorized?, :handle_unauthorized
    # /// ログイン中のユーザーとdataのユーザーが一致するかをbool値で返す
    def authorized?(data)
        # data.user_id === current_user.id
        data[:user_id] === current_user.id
    end

    # /// dataのユーザーとログインユーザーが不一致な場合の処理
    def handle_unauthorized(data)
        unless authorized?(data)
            render json: { messages: "アクセス権限がありません。", status: 401 }
        end
    end

    # /// releaseが真かどうか確認
    def release?(data)
        !!data[:release] || !data[:release] && authorized?(data)
    end
# validates ==================================================================================

# novels 小説系機能============================================================================

    # NovelSeriesオブジェクト全件を取得するメソッド============================================
        helper_method :create_new_series_object, :return_all_series_object

        # /// create_new_series_objectで作成したNovelSeriesオブジェクト全件を返す
        # /// NovelSeriesコントローラのindexにて使用
        # /// dataには、NovelSeries全件のデータが渡される
        def return_all_series_object(data)
            data.map do |value|
                # シリーズが公開されている場合
                # ここではrelease?()メソッドは使用しない
                if !!value[:release]
                    # 個々の新たなシリーズデータを生成
                    create_new_series_object(value, "all_of_series_data")
                # シリーズが非公開の場合
                elsif !value[:release]
                    {}
                end
            end
        end

        # /// 渡されたdataに基づいて新たなNovelSeriesオブジェクトを生成
        # /// return_all_series_data()メソッド, NovelSeriesコントローラのshowアクションにて使用
        def create_new_series_object(series, data_type)
            # NovelSeriesオブジェクトの所有するNovels(@novels)/Novelsの総数(@novels_count)/登録されているNovelTags(@series_tags)を返す
            return_novels_and_novels_count_and_tags(series, true)
            # Novelオブジェクトが獲得したNovelFavorites(@favorites_count)/Comments(@comments_count)を返す
            return_count_of_favorites_and_comments(@novels)
            # novels NovelSeriesオブジェクトを全件取得したい場合
            if data_type === "all_of_series_data"
                # return_all_series_data()メソッドへ
                return_new_one_series_object(
                    series, @novels_count, @favorites_count, @comments_count, @series_tags, {}
                )
            # novels NovelSeriesオブジェクトを1件取得したい場合
            elsif data_type === "one_of_series_data"
                # validates 公開の場合／もしくは非公開でもログインユーザーと同じだった場合
                if release?(series)
                    # novels 新たなNovelSeriesオブジェクトを生成する
                    @series = return_new_one_series_object( series, @novels_count, @favorites_count, @comments_count, @series_tags, @novels )
                    # JSONデータをレンダリング
                    render json: {
                        status: 200,
                        series: @series,
                        keyword: "show_of_series"
                    }
                # validates 非公開の場合
                elsif !release?(series)
                    # JSONデータをレンダリング
                    return_unrelease_data()
                end
            end
        end

        # /// 1件のNovelSeriesが所有するNovels全件のデータ/Novelsの総数/NovelTagsを返す
        # /// create_new_series_object(), create_new_novel_object()にて使用
        def return_novels_and_novels_count_and_tags(series_data, data_type)
            # NovelSeriesの持つNovels全件
            @novels = Novel.where(novel_series_id: series_data.id)
            # Novels全件の総数
            @novels_count = @novels.count
            # tags data_typeがtrueの場合はNovelTagsオブジェクトが欲しいので、NovelTagsオブジェクトを生成
            if !!data_type
                @series_tags = series_data.novel_tags.map { |tag|
                    ["tag_id": tag.id, "tag_name": tag.novel_tag_name]
                }.flatten
            end
        end

        # /// あるNovelSeries1件が持つNovels全件が獲得したNovelFavoritesの数／Commentsの数を返す
        # /// create_new_series_object()にて使用
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

        # /// 新たにNovelSeriesオブジェクト全件を生成するためのフォーマット
        # /// create_new_series_object()メソッドにて使用
        def return_new_one_series_object(series, nov_count, fav_count, com_count, tags, novels)
            return {
                id: series.id,    # NovelSeries1件に対するID
                user_id: series.user_id,  # NovelSeriesに紐付くユーザーのID
                author: series.author,  # NovelSeriesの作者
                release: series.release,    # NovelSeriesが公開か非公開か
                series_title: series.series_title,   # NovelSeriesのタイトル
                series_description: series.series_description,  # NovelSeriesのあらすじ
                novels_count: nov_count,     # NovelSeriesが持つNovels全件の総数
                favorites_count: fav_count,   # Novelsが獲得したNovelFavoritesの総数
                comments_count: com_count,     # Novelsが獲得したCommentsの総数
                tags: tags,      # NovelSeriesに登録されているNovelTags
                novels: novels  # NovelSeriesが持つNovels全件
            }
        end
    # novels===================================================================================

    # novels Novelオブジェクトを取得するメソッド===============================================
        helper_method :create_new_novel_object, :data_of_comments_in_novel

        # /// 新たに1件のNovelsオブジェクトを生成する
        # /// NovelsControllerのshowアクションにて使用
        def create_new_novel_object(series_data, novel_data)
            # validates 公開されている場合
            if release?(novel_data)
                # novels Novels全件(@novels)／Novelsの総数(@novels_count)を取得
                return_novels_and_novels_count_and_tags(series_data, false)
                # お気に入りをしたUsersのデータ(@favorites_data)／NovelFavoritesの数(@favorites_count)
                data_of_favorites_in_novel(novel_data)
                # コメントをしたUsersのデータ(@comments_data)／Commentsの数(@comments_count)
                data_of_comments_in_novel(novel_data)
                # novels 新たに生成したNovelsオブジェクト1件を返す
                @novel = return_new_one_novel_object(series_data, novel_data, @novels_count, @favorites_data, @favorites_count, @comments_data, @comments_count)
                render json: {
                    status: 200,
                    novel: @novel,
                    keyword: "show_of_novels"
                }
            # validates 非公開の場合
            elsif !release?(novel_data)
                # JSONデータをレンダリング
                return_unrelease_data()
            end
        end

        # /// シリーズが所有する小説データ1件のデータフォーマット
        # /// create_new_novel_object()メソッドにて使用
        def return_new_one_novel_object(series_data, novel_data, novels_count, favorites_data, favorites_count, comments_data, comments_count)
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

        # /// 小説1件に対するお気に入りデータ
        # /// create_new_novel_object()メソッドにて使用
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

        # /// 小説1件に対するコメントデータ
        # /// create_new_novel_object()メソッドにて使用
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
    # novels ==================================================================================


    # novels Reactから送られてくるパラメータを基にオブジェクトを作成・保存・更新したり、編集用オブジェクトをJSONで返すメソッド===============
        helper_method :save_new_object_to_db, :update_object_to_db, :get_edit_object

        # /// 引数に渡されるデータに基づいて、新規のオブジェクトをDBに保存するメソッド
        # /// new_object = 新規作成するオブジェクト
        # /// association_data = NovelSeriesオブジェクト or NovelTagオブジェクト
        # /// data_type = novel or series
        def save_new_object_to_db(new_object, association_data, data_type)
            if data_type === "novel"
                # Novelを保存しようとしているNovelSeriesのuser_idとcurrent_userのidが一致しているかどうかを確認
                if authorized?(association_data)
                    new_object.user_id = current_user.id    # NovelSeriesのID
                    new_object.author = current_user.nickname  # NovelSeriesの作者
                    if new_object.save
                        series_and_novel_json_to_render(
                            new_object,
                            "created",
                            "正常に保存されました。",
                            "create_of_novels"
                        )
                    else
                        return_failed_to_create_error(new_object)
                    end
                else
                    handle_unauthorized(association_data)
                end
            elsif data_type === "series"
                if new_object.save
                    # tags set_series_tagsメソッドに基づきNovelSeriesオブジェクトにNovelTagを登録
                    new_object.save_tag(association_data)
                    series_and_novel_json_to_render(
                        new_object,
                        "created",
                        "正常に保存されました。",
                        "create_of_series"
                    )
                else
                    return_failed_to_create_error(new_object)
                end
            end
        end

        # /// 引数に渡されるデータに基づいて、オブジェクトをDBに更新するメソッド
        # /// object = 更新するオブジェクト
        #/// params = パラメータ
        # /// association_data = NovelTagオブジェクト
        # /// data_type = novel or series
        def update_object_to_db(object, params, association_data, data_type)
            if authorized?(object)
                if object.update(params)
                    # set_series_tagsメソッドに基づきNovelSeriesオブジェクトにタグを登録
                    if data_type === "series"
                        object.save_tag(association_data)
                        series_and_novel_json_to_render(
                            object,
                            "ok",
                            "編集が完了しました。",
                            "update_of_series"
                        )
                    elsif data_type === "novel"
                        series_and_novel_json_to_render(
                            object,
                            "ok",
                            "編集が完了しました。",
                            "update_of_novels"
                        )
                    end
                else
                    return_failed_to_create_error(object)
                end
            else
                handle_unauthorized(object)
            end
        end

        #/// 引数に渡されるデータに基づいて、Novel/NovelSeriesを編集するためのオブジェクトを取得する
        #/// object = 編集するオブジェクト
        #/// data_type = novel or series
        def get_edit_object(object, data_type)
            # 取得したオブジェクトのユーザーIDと、ログインユーザーのIDが一致することをチェック
            if authorized?(object)
                #novels Novel編集用のJSONを取得
                if data_type === "novel"
                    series_and_novel_json_to_render( object, 200, {}, "edit_of_novels" )
                # NovelSeries編集用のJSONを取得
                elsif data_type ==="series"
                    series_and_novel_json_to_render( object, 200, {}, "edit_of_series")
                end
            else
                handle_unauthorized(object)
            end
        end

        #/// NovelSeries/Novelオブジェクトをcreate, edit, updateする際に返すJSONデータ
        #/// save_new_object_to_db(), update_object_to_db(), get_edit_object()にて使用
        def series_and_novel_json_to_render(object, status, message, keyword)
            @object =
            # React側でリダイレクトに使用するためのパラメータを返す
            if keyword === "create_of_novels" || keyword === "update_of_novels"
                {
                    novel_id: object.id,
                    series_id: object.novel_series_id
                }
            # React側でリダイレクトに使用するためのパラメータを返す
            elsif keyword === "create_of_series" || keyword === "update_of_series"
                object.id
            # React側で編集するためのNovelオブジェクトを返す
            elsif keyword === "edit_of_novels"
                {
                    novel_id: object.id,
                    user_id: object.user_id,
                    novel_title: object.novel_title,
                    novel_description: object.novel_description,
                    novel_content: object.novel_content,
                    release: object.release,
                }
            # React側で編集するためのSeriesオブジェクを返す
            elsif keyword === "edit_of_series"
                {
                    series_id: object.id,
                    user_id: object.user_id,
                    series_title: object.series_title,
                    series_description: object.series_description,
                    release: object.release,
                    # ["タグ1", "タグ2"]のような形で取得
                    series_tags: remake_arr_to_new_object(object.novel_tags, "edit_of_series")
                }
            end
            # JSONを返す
            render json: {
                status: status,
                object: @object,
                successful: message,
                keyword: keyword
            }
        end
    # novels ==================================================================================

# novels ======================================================================================

# object 新たにオブジェクトを生成するメソッド================================================
    helper_method :remake_arr_to_new_object

    # /// 新たに作成したいオブジェクトを返す。ここでは"配列"データを各々のオブジェクト化するメソッドへ渡している。
    # /// UserTagsコントローラ, NovelTagsコントローラ, series_and_novel_json_to_render()にて使用
    def remake_arr_to_new_object(data, data_type)
        data.map do |d|
            # tags UserTagsオブジェクト全件返す
            if data_type === "user_tag"
                return_new_tag_object(d, "user_tag")
            # tags NovelTagsオブジェクト返す
            elsif data_type ==="series_tag"
                return_new_tag_object(d, "series_tag")
            # Usersオブジェクトを返す
            elsif data_type === "user"
                return_new_user_object(d)
            # NovelSeries編集用のNovelTagsオブジェクトを返す
            elsif data_type === "edit_of_series"
                return_new_tag_object(d, "edit_of_series")
            end
        end
    end
# object ==================================================================================

# ユーザー系機能===========================================================================
    helper_method :return_new_user_object

    # /// ユーザーデータの新たなオブジェクトを生成する
    # /// remake_arr_to_new_object()にてループ処理されたデータをここでオブジェクトへ変換。
    def return_new_user_object(user)
        return {
            user_id: user.id,
            nickname: user.nickname,
            profile: user.profile,
        }
    end
# =========================================================================================

# tags タグ系機能==========================================================================
    helper_method :return_new_tag_object

    # /// NovelTags/UserTagsの新たなオブジェクトを生成する
    # /// 主にremake_arr_to_new_object()にてループ処理されたデータをここでオブジェクト化する。
    def return_new_tag_object(tag, tags_type)
        # UserTags
        if tags_type === "user_tag"
            return {
                tag_id: tag.id,
                tag_name: tag.user_tag_name,
                count: tag.users.count,
            }
        # NovelTags
        elsif tags_type ==="series_tag"
            return {
                tag_id: tag.id,
                tag_name: tag.novel_tag_name,
                count: tag.novel_series.count,
            }
        # NovelSeries編集用のNovelTags
        # ["タグ1", "タグ2"]のような形で取得
        elsif tags_type === 'edit_of_series'
            tag.novel_tag_name
        end
    end
# tags ====================================================================================

# error 不正なデータ取得をしてしまった際のレスポンス========================================
    helper_method :return_not_present_data, :return_unrelease_data, :return_failed_to_create_error

    # /// データが存在しない場合に返すJSONレスポンス
    # /// NovelSeriesコントローラのprivate, Novelsコントローラのprivateにて使用
    def return_not_present_data
        render json: {
            status: 500,
            errors: "作品が存在しないため、アクセスできません。",
            keyword: "not_present"
        }
    end

    # /// データが非公開の場合に返すレスポンス
    # /// create_new_series_object(), create_new_novel_object()にて使用
    def return_unrelease_data
        # React側へ送信するJSONデータ
        render json: {
            status: 200,
            messages: "現在この作品は非公開となっています。",
            keyword: "unrelease"
        }
    end

    # /// saveしようとしたオブジェクトが不正だった場合に返すレスポンス
    # /// series_or_novel
    def return_failed_to_create_error(new_object)
        render json: {
            status: :unprocessable_entity,
            errors: new_object.errors.full_messages,
        }
    end
# error ====================================================================================
end
