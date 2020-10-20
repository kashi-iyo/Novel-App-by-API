module NovelSeriesHelper

    include ReturnObjectForRenderJsonHelper
    include ReturnEachDataHelper

#generate_original_object React側で使用するために、オブジェクトを新たな形に構築する=========================

        # data_typeによって生成するオブジェクトを条件分岐
        def return_object_by_data_type(object, object2, data_type)
            case data_type
                #! NovelTags#index, object = NovelTag.all
                #! UserTags#index, object = UserTag.all
            when "NovelSeries#index", "UserTags#show", "NovelTags#show",
                    "NovelTags#index", "UserTags#index"
                new_object = generate_object_from_arr(object, data_type)
                case data_type
                when "NovelTags#index","UserTags#index"
                    return new_object
                    #! series_index, object = NovelSeries.all
                when "NovelSeries#index"
                    return_all_series_object_for_render_json(new_object, {}, data_type)
                    #! UserTags#show, object = Users全件, object2 = UserTag1件
                    #! NovelTags#show, object = NovelSeries全件, object2 = NovelTag1件
                when "UserTags#show", "NovelTags#show"
                    tag = return_tag_data(object2, data_type)
                    case data_type
                    when "UserTags#show"
                        return_users_object_for_render_json(tag, new_object)
                    when "NovelTags#show"
                        return_all_series_object_for_render_json(new_object, tag, data_type)
                    end
                end
            #! NovelSeries#show, object = NovelSeries1件
            when "NovelSeries#show"
                generate_original_series_object(object, data_type)
            #! Novel#show, object = NovelSeries1件, object2 = Novel1件
            when "Novels#show"
                generate_original_novel_content_object(object, object2, data_type)
            end
        end

        #generate_original_object 配列データを新たなオブジェクトへ造り変える
        def generate_object_from_arr(array, data_type)
            array.map do |data|
                case data_type
                #! NovelSeriesオブジェクト全件を返す
                when "NovelSeries#index", "NovelTags#show"
                    #validates シリーズが公開されている場合。ここではrelease?()メソッドは使用しない
                    if !!data[:release]
                        generate_original_series_object(data, data_type)
                    #validates シリーズが非公開の場合
                    elsif !data[:release]
                        {}
                    end
                # NovelFavorites / Commentsをカウントしたデータを返す
                when "call_favorites_count", "call_comments_count"
                    items_counter(data, data_type)
                # NovelFavoritesオブジェクトを返す
                when "favorites_count"
                    generate_original_favorites_object(data, data_type)
                #! Novelsオブジェクトをお気に入りしたユーザーを返す
                when "call_return_favorites_data"
                    return_favorites_data(data, data_type)
                # Commentsオブジェクトを返す
                when "comments_count", "comments_in_novel"
                    generate_original_comments_object(data, data_type)
                when "call_return_comments_data"
                    return_comments_data(data, data_type)
                # UserTags / NovelTagsオブジェクトを返す
                when "call_return_tag_data", "edit_of_series", "UserTags#index", "NovelTags#index"
                    return_tag_data(data, data_type)
                #! Novelsオブジェクトを返す
                when "UserTags#show"
                    return_user_data(data, data_type)
                end
            end
        end

        #generate_original_object NovelSeriesオブジェクトを生成
        def generate_original_series_object(series, data_type)
            #! NovelSeriesデータの生成
            @series = return_series_data(series, data_type)
            #! Novelsデータ / NovelFavoritesデータ / Commentsデータ生成
            @novels = generate_original_novel_object(series, data_type)
            #! NovelTagsデータ生成
            @tags = generate_object_from_arr(series.novel_tags, "call_return_tag_data")
            case data_type
            #! series_index, NovelTags#showの場合
            when "NovelSeries#index","NovelTags#show"
                return_original_series_data(@series, @novels, @tags, data_type)
            #! NovelSeries#show / Novels#showの場合
            when "NovelSeries#show"
                # validates 公開の場合／もしくは非公開でもログインユーザーと同じだった場合
                if release?(series)
                    return_one_series_object_for_render_json(@series, @novels, @tags)
                # validates 非公開の場合
                elsif !release?(series)
                    #render_json JSONデータをレンダリング
                    return_unrelease_data()
                end
            end
        end

        #generate_original_object 新たな構造の1件のNovelsオブジェクトを生成する。
        def generate_original_novel_content_object(series_data, novel_data, data_type)
            # validates 公開されている場合
            if release?(novel_data)
                #! NovelSeriesデータ
                series = return_series_data(series_data, data_type)
                #! Novelsデータ
                novel = generate_original_novel_object(novel_data, data_type)
                # NovelFavoritesデータ
                favorites = generate_original_favorites_object(novel_data, data_type)
                # Commentsデータ
                comments = generate_original_comments_object(novel_data, data_type)
                #! 取得したデータを渡してNovelsオブジェクトを生成
                return_one_novel_object_for_render_json(series, novel, favorites, comments)
                # return_one_novel_object_for_render_json(series, novel, favorites, comments)
            # validates 非公開の場合
            elsif !release?(novel_data)
                #render_json JSONデータをレンダリング
                return_unrelease_data()
            end
        end

        #generate_original_object
        #! Novelsオブジェクト / Novels総数 / NovelFavoritesオブジェクト / Commentsオブジェクト生成
        # object = novel1件, series1件
        def generate_original_novel_object(object, data_type)
            case data_type
            when "NovelSeries#index", "NovelSeries#show", "NovelTags#show"
                #! Novels全件
                @novels = object.novels
                # NovelFavorites数の合計値
                favorites = generate_original_favorites_object(@novels, data_type)
                # Comments数の合計値
                comments = generate_original_comments_object(@novels, data_type)
                case data_type
                when "NovelSeries#index", "NovelTags#show"
                    @novels_count = @novels.count
                    return_original_novel_data_in_one_series(@novels_count, favorites, comments, data_type)
                when "NovelSeries#show"
                    return_original_novel_data_in_one_series(@novels, favorites, comments, data_type)
                end
            when "Novels#show"
                return_one_novel_data(object)
            end
        end

        #!generate_original_object
        #! NovelFavoritesオブジェクト
        def generate_original_favorites_object(novel_data, data_type)
            case data_type
            when "NovelSeries#index", "NovelTags#show", "NovelSeries#show"
                # 各NovelのNovelFavoritesのカウント
                count = generate_object_from_arr(novel_data, "call_favorites_count")
                return_original_favorites_data(count, data_type)
            when "Novels#show"
                return_original_favorites_data(novel_data, data_type)
            end
        end

        #!generate_original_object
        # Commentsオブジェクト生成
        def generate_original_comments_object(novel_data, data_type)
            case data_type
            #! NovelSeriesから取得する場合
            when "NovelSeries#index", "NovelTags#show", "NovelSeries#show"
                # Novelの持つコメント数
                count = generate_object_from_arr(novel_data, "call_comments_count")
                # コメント総の合計値
                return_original_comments_data(count, data_type)
            # Novelから取得する場合
            when "Novels#show"
                return_original_comments_data(novel_data, data_type)
            end
        end


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