module NovelSeriesHelper

    # create
    # read
    # edit
    # update
    # destroy
    # validates
    # render_json： JSONデータのレンダリングはhelperで行えないのでApplicationControllerにて行っている。
    # generate_original_object

#! シリーズ全件／1件のシリーズを表示するために必要なオブジェクトを取得する=========================

        #read create_new_series_object()で作成したNovelSeriesオブジェクト全件を返す
        #read NovelSeries#indexにて使用
        def return_all_series_object(data)
            data.map do |value|
                # if data_type === "all_series"
                    #validates シリーズが公開されている場合。ここではrelease?()メソッドは使用しない
                    if !!value[:release]
                        #generate_original_object 個々の新たなシリーズデータを生成
                        create_new_series_object(value, "all_of_series_data")
                    #validates シリーズが非公開の場合
                    elsif !value[:release]
                        {}
                    end
                # elsif data_type === "user_tag"
                #     return_new_tag_object(value, "user_tag")
                # elsif data_type ==="series_tag"
                #     return_new_tag_object(value, "series_tag")
                # elsif data_type === "user"
                #     return_new_user_object(value)
                # #! NovelSeries編集用のNovelTagsオブジェクトを返す
                # elsif data_type === "edit_of_series"
                #     return_new_tag_object(value, "edit_of_series")
                # end
            end
        end

        #generate_original_object 渡されたdataに基づいて新たなNovelSeriesオブジェクトを生成、return_all_series_data(), NovelSeries#showにて使用
        def create_new_series_object(series, data_type)
            #! NovelSeriesオブジェクトの所有するNovels(@novels)/Novelsの総数(@novels_count)/登録されているNovelTags(@series_tags)を返す
            return_novels_and_novels_count_and_tags(series, true)
            # Novelオブジェクトが獲得したNovelFavorites(@favorites_count)/Comments(@comments_count)を返す
            return_count_of_favorites_and_comments(@novels)
            # #! novels NovelSeriesオブジェクトを全件取得したい場合
            if data_type === "all_of_series_data"
                #render_json JSONデータをレンダリング
                render_series_object(
                    series,
                    @novels_count,
                    @favorites_count,
                    @comments_count,
                    @series_tags,
                    {},
                    # "index_of_series"
                )
            #! novels NovelSeriesオブジェクトを1件取得したい場合
            elsif data_type === "one_of_series_data"
                # validates 公開の場合／もしくは非公開でもログインユーザーと同じだった場合
                if release?(series)
                    render_series_object(
                        series,
                        @novels_count,
                        @favorites_count,
                        @comments_count,
                        @series_tags,
                        @novels,
                        "show_of_series"
                    )
                # validates 非公開の場合
                elsif !release?(series)
                    #render_json JSONデータをレンダリング
                    return_unrelease_data()
                end
            end
        end

        #generate_original_object 1件のNovelSeriesが所有するNovels全件のデータ/Novelsの総数/NovelTagsを返す。create_new_series_object(), create_new_novel_object()にて使用
        def return_novels_and_novels_count_and_tags(series_data, data_type)
            #! 1つのNovelSeriesの持つNovels全件
            @novels = Novel.where(novel_series_id: series_data.id)
            #! Novels全件の総数
            @novels_count = @novels.count
            #! data_typeがtrueの場合はNovelTagsオブジェクトが欲しいので、NovelTagsオブジェクトを生成
            if !!data_type
                @series_tags = series_data.novel_tags.map { |tag|
                    ["tag_id": tag.id, "tag_name": tag.novel_tag_name]
                }.flatten
            end
        end

        #generate_original_object NovelSeries1件が持つNovels全件が獲得したNovelFavoritesの数／Commentsの数を返す。create_new_series_object()にて使用
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
#=================================================================================================

#! 1つのシリーズが所有する小説1件の内容を表示するために必要なオブジェクトを取得する================

    #generate_original_object 新たに1件のNovelsオブジェクトを生成する。NovelsControllerのshowアクションにて使用
    def create_new_novel_object(series_data, novel_data)
        # validates 公開されている場合
        if release?(novel_data)
            #! Novels全件(@novels)／Novelsの総数(@novels_count)を取得
            return_novels_and_novels_count_and_tags(series_data, false)
            #! お気に入りをしたUsersのデータ(@favorites_data)／NovelFavoritesの数(@favorites_count)
            data_of_favorites_in_novel(novel_data)
            # コメントをしたUsersのデータ(@comments_data)／Commentsの数(@comments_count)
            data_of_comments_in_novel(novel_data)
            # render_json JSONデータを返す
            return_new_one_novel_object(
                series_data,
                novel_data,
                @novels_count,
                @favorites_data,
                @favorites_count,
                @comments_data,
                @comments_count,
                "show_of_novels"
            )
        # validates 非公開の場合
        elsif !release?(novel_data)
            #render_json JSONデータをレンダリング
            return_unrelease_data()
        end
    end

    # generate_original_object 小説1件に対するお気に入りデータ。create_new_novel_object()メソッドにて使用
    def data_of_favorites_in_novel(novel)
        # もしお気に入りされていない場合は、空の配列を返す。これは、React側でfavorites_idによってお気に入りの有無を判別するため
        if novel.novel_favorites === []
            @favorites_data = [
                favorites_id: "",
            ]
        # このお気に入りデータのID、お気に入りしたユーザー、そのユーザーのID、お気に入りされた小説のIDを返す
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

    #generate_original_object 小説1件に対するコメントデータ。create_new_novel_object()メソッドにて使用
    def data_of_comments_in_novel(novel)
        # このコメントのID、コメントをしたユーザーとユーザーのID、コメントを残された小説のID、コメントの内容
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