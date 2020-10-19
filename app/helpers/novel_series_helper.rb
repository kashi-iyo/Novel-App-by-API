module NovelSeriesHelper

    # create
    # read
    # edit
    # update
    # destroy
    # validates
    # render_json： JSONデータのレンダリングはhelperで行えないのでApplicationControllerにて行っている。
    # generate_original_object

#generate_original_object React側で使用するために、オブジェクトを新たな形に構築する=========================

        #generate_original_object data_typeによって生成するオブジェクトを条件分岐
        def return_object_by_data_type(object, object2, data_type)
            case data_type
            # object = NovelSeries
            when "index_of_series"
                series = generate_object_from_arr(object, data_type)
                {
                    series_count: series.count,
                    all_series: series,
                }
            when "show_of_users_in_tag", "show_of_series_in_tag"
                objects = generate_object_from_arr(object, data_type)
                tag = return_tag_object(object2, data_type)
                {
                    tag: tag,
                    objects_count: objects.count,
                    objects: objects,
                }
            when "index_of_series_tags", "index_of_user_tags"
                generate_object_from_arr(object, data_type)
            when "show_of_series"
                create_new_series_object(object, data_type)
            when "show_of_novels"
                # object = series1件, novel1件
                create_new_novel_object(object, object2, data_type)
            end
        end

        #generate_original_object 配列データを新たなオブジェクト形式へ造り変える
        def generate_object_from_arr(array, data_type)
            array.map do |data|
                case data_type
                # ! NovelSeriesオブジェクトを返す
                when "index_of_series", "show_of_series_in_tag"
                    #validates シリーズが公開されている場合。ここではrelease?()メソッドは使用しない
                    if !!data[:release]
                        create_new_series_object(data, data_type)
                    #validates シリーズが非公開の場合
                    elsif !data[:release]
                        {}
                    end
                # NovelFavoritesをカウントしたデータを返す
                when "items_counter_in_favo", "items_counter_in_com"
                    items_counter(data, data_type)
                # NovelFavoritesオブジェクトを返す
                when "call_create_favorites_object"
                    create_favorites_object(data, data_type)
                #! Novelsオブジェクトをお気に入りしたユーザーを返す
                when "call_favorites_data"
                    favorites_data(data, data_type)
                # Commentsオブジェクトを返す
                when "comments_in_series", "comments_in_novel"
                    create_comments_object(data, data_type)
                when "call_comments_data"
                    comments_data(data, data_type)
                # UserTags / NovelTagsオブジェクトを返す
                when "index_of_series_tags", "edit_of_series", "index_of_user_tags"
                    return_tag_object(data, data_type)
                #! Novelsオブジェクトを返す
                when "show_of_users_in_tag"
                    return_user_object(data, data_type)
                end
            end
        end

        #generate_original_object NovelSeriesオブジェクトを生成
        def create_new_series_object(object, data_type)
            #! NovelSeriesデータの生成
            @series = return_series_data(object, data_type)
            #! Novelsデータ / NovelFavoritesデータ / Commentsデータ生成
            @novels = return_novels_object(object, {}, data_type)
            #! NovelTagsデータ生成
            @tags = generate_object_from_arr(object.novel_tags, "index_of_series_tags")
            case data_type
            #! NovelSeries#index, NovelTags#showの場合
            when "index_of_series", "show_of_series_in_tag"
                return_series_object(@series, @novels, @tags)
            #! NovelSeries#show / Novels#showの場合
            when "show_of_series", "show_of_novels"
                # validates 公開の場合／もしくは非公開でもログインユーザーと同じだった場合
                if release?(object)
                    case data_type
                    when "show_of_series"
                        return_series_object(@series, @novels, @tags)
                    end
                # validates 非公開の場合
                elsif !release?(object)
                    #render_json JSONデータをレンダリング
                    return_unrelease_data()
                end
            end
        end

        def return_series_data(series, data_type)
            case data_type
            when "show_of_novels"
                return {
                    series_id: series.id,
                    user_id: series.user_id,
                    author: series.author,
                    release: series.release,
                    series_title: series.series_title,
                    series_description: series.series_description,
                }
            end
        end

        #generate_original_object 新たな構造の1件のNovelsオブジェクトを生成する。
        def create_new_novel_object(series_data, novel_data, data_type)
            # validates 公開されている場合
            if release?(novel_data)
                series = return_series_data(series_data, data_type)
                #! Novelsオブジェクト
                novel = return_novels_object(novel_data, data_type)
                # NovelFavoritesオブジェクト
                favorites = create_favorites_object(novel_data, data_type)
                # Commentsオブジェクト
                comments = create_comments_object(novel_data, data_type)
                #! Novelsオブジェクトを返す
                return_new_one_novel_object(series, novel, favorites, comments)
            # validates 非公開の場合
            elsif !release?(novel_data)
                #render_json JSONデータをレンダリング
                return_unrelease_data()
            end
        end

        #generate_original_object
        #! Novelsオブジェクト / Novels総数 / NovelFavoritesオブジェクト / Commentsオブジェクト生成
        def return_novels_object(novel_data, data_type)
            # NovelFavorites総数
            # favorites_object = create_favorites_object(@novels, "call_create_favorites_object")
            # # Comments総数
            # comments_object = create_comments_object(@novels, "comments_in_series")
            case data_type
            when "show_of_series", "index_of_series", "show_of_series_in_tag"
                #! Novels全件
                # @novels = series_data.novels
                # return_novels_data(@novels, data_type)
                    # {
                    #!     novels_count: novels_count,
                    #     favorites_count: favorites_object,
                    #     comments_count: comments_object,
                    # }
                    # {
                    #!     novels_count: novels_count,
                    #     favorites_count: favorites_object,
                    #     comments_count: comments_object,
                    #!    novels: @novels,
                    # }
            when "show_of_novels"
                return {
                    novel_id: novel_data.id,
                    release: novel_data.release,
                    novel_title: novel_data.novel_title,
                    novel_description: novel_data.novel_description,
                    novel_content: novel_data.novel_content,

                }
                # {
                #!     novels_count: novels_count,
                #!     novels: @novels,
                #     favorites_object: favorites_object,
                #     commenst_object: comments_object,
                # }

            end
        end

        # NovelFavoritesの数 / Commentsの数
        # それぞれの値の合計値を算出するには、一旦generate_object_from_arr()を介す必要がある。
        # item = novel
        def items_counter(item, data_type)
            case data_type
            when "items_counter_in_favo"
                [favorites_count: item.novel_favorites.count]
            when "items_counter_in_com"
                [comments_count: item.comments.count]
            end
        end

        #! NovelFavoritesオブジェクト
        def create_favorites_object(novel_data, data_type)
            case data_type
            #! NovelSeriesから取得する場合
            when "call_create_favorites_object"
                # NovelFavoritesの総数
                count = generate_object_from_arr(novel_data, "items_counter_in_favo")
                count.flatten.sum {|hash| hash[:favorites_count]}
            #! Novelから取得する場合
            when "show_of_novels"
                if novel_data.novel_favorites === []
                    return {
                        favorites_count: novel_data.novel_favorites.count,
                        favorites_id: "",
                    }
                else
                    return {
                        favorites_count: novel_data.novel_favorites.count,
                        favorites_data: generate_object_from_arr(novel_data.novel_favorites, "call_favorites_data"),
                    }
                end
            end
        end

        #! Novelsにされたお気に入り1件のデータフォーマット
        def favorites_data(favorites, data_type)
            case data_type
            when "call_favorites_data"
                return {
                    favorites_id: favorites.id,
                    favorites_user_id: favorites.user_id,
                    favorites_novel_id: favorites.novel_id,
                    favoriter: favorites.favoriter,
                }
            end
        end

        # Commentsオブジェクト生成
        def create_comments_object(novel_data, data_type)
            case data_type
            #! NovelSeriesから取得する場合
            when "comments_in_series"
                # Novelの持つコメント数
                count = generate_object_from_arr(novel_data, "items_counter_in_com")
                # コメント総の合計値
                count.flatten.sum{|hash| hash[:comments_count]}
            # Novelから取得する場合
            when "show_of_novels"
                return {
                    comments_count: novel_data.comments.count,
                    comments_data: generate_object_from_arr(novel_data.comments, "call_comments_data"),
                }
            end
        end

        #! Novelsにされたコメント1件のデータフォーマット
        def comments_data(comment, data_type)
            case data_type
            when "call_comments_data"
                return {
                    comment_id: comment.id,
                    comment_user_id: comment.user_id,
                    comment_novel_id: comment.novel_id,
                    comment_content: comment.content,
                    comment_commenter: comment.commenter,
                }
            end
        end

        # NovelTags / UserTags
        #generate_original_object タグ系のオブジェクト構造フォーマット
        def return_tag_object(tag, tags_type)
            case tags_type
            #! NovelSeries#index, show, NovelTags#index, show
            when "index_of_series_tags", "show_of_series_in_tag", "other_series_case"
                return {
                    tag_id: tag.id,
                    tag_name: tag.novel_tag_name,
                    count: tag.novel_series.count,
                }
            # UserTags#index, show
            when "index_of_user_tags", "show_of_users_in_tag"
                return {
                    tag_id: tag.id,
                    tag_name: tag.user_tag_name,
                    count: tag.users.count,
                }
            #! NovelSeries#edit
            # ["タグ1", "タグ2"]のような形で取得。(React側では配列として扱いたいため)
            when 'edit_of_series'
                tag.novel_tag_name
            end
        end

        #generate_original_object ユーザーオブジェクト構造のフォーマット
        def return_user_object(user, user_type)
            if user_type === "show_of_users_in_tag"
                return {
                    user_id: user.id,
                    nickname: user.nickname,
                    profile: user.profile,
                }
            end
        end

        #generate_original_object NovelSeriesのオブジェクト構造のフォーマット
        def return_series_object(series, novels, tags)
            return {
                series: series,
                novels: novels,
                tags: tags,
            }
        end


        #generate_original_object 新たな構造のNovelsオブジェクトのフォーマット。
        def return_new_one_novel_object(series, novel, favorites, comments)
            return {
                series: series,
                novel: novel,
                favorites: favorites,
                comments: comments
            }
        end
# =================================================================================================


#! Reactから送られてくるパラメータを基にデータをCreate・Save・Update、Editする=====================

    # Reactから送信されるオブジェクトが認可されているかどうかをチェック
    # object = CRUDするオブジェクト
    # params = パラメータ
    # association_data = オブジェクトとアソシエーションされたデータ
    # data_type = どのモデルを扱うか
    # crud_type = どのCRUDなのか判別
    def pass_object_to_crud(object, params, association_data, data_type, crud_type)
        #validates objectのuser_idとcurrent_userのidが一致しているかどうかを確認
        if authorized?(data_type === "novel2" ? association_data : object)
            #! 受け取ったデータを基にオブジェクトをCRUDする
            crud_object(object, params, association_data, data_type, crud_type)
        # validates 認可失敗
        else
            handle_unauthorized(data_type === "novel2" ? association_data : object)
        end
    end

    #! オブジェクトをCreate, Edit, Update, Destroyするそれぞれのメソッドへ渡す
    def crud_object(object, params, association_data, data_type, crud_type)
        #Create・Save
        if crud_type === "create"
            create_and_save_object(object, association_data, data_type)
        # Edit
        elsif crud_type === "edit"
            get_object_for_edit(object, association_data, data_type)
        # Update
        elsif crud_type === "update"
            update_object(object, params, association_data, data_type)
        # Destroy
        elsif crud_type === "destroy"
            destroy_object(object, data_type)
        end
    end

    #Create オブジェクトをCreate・Save
    def create_and_save_object(new_object, association_data, data_type)
        #  Novelの場合は以下の処理によりユーザーとの関連付けを行う
        if data_type === "novel2"
            new_object.novel_series_id = association_data.id    #! NovelSeriesのID
            new_object.author = association_data.author         #! NovelSeriesの作者
        end
        #validates 保存
        if new_object.save
            #! Novelsオブジェクト
            if data_type === "novel2"
                # render_json この時点でJSONデータがレンダリングされる。（ApplicationControllerにて）
                create_and_save_object_to_render(new_object, "create_of_novels" )
            #! NovelSeriesオブジェクト
            elsif data_type === "series"
                #! NovelSeriesオブジェクトにNovelTagを登録
                new_object.save_tag(association_data)
                # render_json この時点でJSONデータがレンダリングされる。（ApplicationControllerにて）
                create_and_save_object_to_render(new_object, "create_of_series" )
            end
        #validates 保存失敗
        else
            # render_json この時点でJSONデータがレンダリングされる。（ApplicationControllerにて）
            failed_to_crud_object(new_object)
        end
    end

    #Edit Editするためのオブジェクトを取得
    def get_object_for_edit(object, association_data, data_type)
        # NovelデータをEditする場合
        if data_type === "novel"
            # render_json この時点でJSONデータがレンダリングされる。（ApplicationControllerにて）
            edit_object_to_render( object, {}, "edit_of_novels" )
        #! NovelSeriesデータをEditする場合
        elsif data_type ==="series"
            # render_json この時点でJSONデータがレンダリングされる。（ApplicationControllerにて）
            edit_object_to_render( object, association_data, "edit_of_series")
        end
    end

    #Update オブジェクトをUpdate
    def update_object(object, params, association_data, data_type)
        #validates データを更新
        if object.update(params)
            #update NovelSeriesデータをUpdateする場合
            if data_type === "series"
                object.save_tag(association_data)
                # render_json この時点でJSONデータがレンダリングされる
                update_object_to_render(object, "update_of_series" )
            #update NovelsデータをUpdateする場合
            elsif data_type === "novel"
                # render_json この時点でJSONデータがレンダリングされる
                update_object_to_render(object, "update_of_novels" )
            end
        #validates 更新失敗
        else
            # render_json この時点でJSONデータがレンダリングされる
            failed_to_crud_object(object)
        end
    end

    #Destroy オブジェクトをDestroy
    def destroy_object(object, data_type)
        #validates データを削除
        if object.destroy
            if data_type === "series"
                destroy_object_to_render("series")
            elsif data_type === 'novel'
                destroy_object_to_render("novel")
            end
        #validates 削除失敗
        else
            # render_json この時点でJSONデータがレンダリングされる
            failed_to_crud_object(object)
        end
    end


# =================================================================================================================

end