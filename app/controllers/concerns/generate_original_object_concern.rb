module GenerateOriginalObjectConcern

    extend ActiveSupport::Concern

    included do
        helper_method :generate_original_series_object, :generate_original_novels_object_for_series, :generate_original_novel_content_object, :generate_original_favorites_object, :generate_original_comments_object, :generate_original_user_page_object
    end


#Read index / showで取得するオリジナルのオブジェクト

    #Series

        #Seriesオブジェクト1件を生成
        #! NovelSeries#index, NovelTags#showで扱う
        #! one_series = NovelSeries1件
        def generate_original_series_object(series_data, data_type)
            # Series1件
            @series = default_series_data(series_data)
            # Novels全件
            @novels = series_data.novels
            # @novels = generate_original_novels_object_for_series(series_data)
            # Favorites数の合計値
            @favorites = generate_original_favorites_object(novels: @novels, data_type: data_type)
            # Comments数の合計値
            @comments = generate_original_comments_object(novels: @novels, data_type: data_type)
            # Stag NovelTags全件
            @tags = generate_object_from_array(series_data.novel_tags, "call_return_tag_data")
            case data_type
            when "series","NovelTags#show", "Users#show"
                # Series1件（新規のデータで構築）
                return_original_series_data(@series, @novels, @tags, type)
            when "NovelSeries#show"
                if release?(series_data)
                    # Series（新規の構造）
                    return_one_series_object_for_render_json(@series, @novels, @tags)
                elsif !release?(series_data)
                    return return_unrelease_data()
                end
            end
        end

        #Novelsオブジェクトを全件（1件のNovelSeriesが所有する全件のNovels）
        #! 新たな構造のNovelsオブジェクト1件を生成する。
        #! （小説データ/お気に入りデータ/コメントデータを持つ）
        #! object = NovelSeries1件
        def generate_original_novels_object_for_series(series_data)
            # Novels全件
            @novels = series_data[:object].novels
            # Favorites数の合計値
            @favorites = generate_original_favorites_object(@novels, data_type)
            # Comments数の合計値
            @comments = generate_original_comments_object(@novels, data_type)
            case series_data[:data_type]
            when "NovelSeries#index", "NovelTags#show", "Users#show"
                @novels_count = @novels.count
                # Novels全件の総数/お気に入り合計値/コメント合計値
                return_original_novel_data_in_one_series(@novels_count, @favorites, @comments, data_type)
            when "NovelSeries#show"
                # Novels全件/お気に入り合計値/コメント合計値
                return_original_novel_data_in_one_series(@novels, @favorites, @comments, data_type)
            end
        end



    #Novels

        #Novelsオブジェクト1件を生成
        #! Novels#showで扱う
        def generate_original_novel_content_object(series_data, novel_data, data_type)
            # validates 公開されている場合
            if release?(novel_data)
                # Seriesデータ1件（1件のSeriesに基づき既存のデータを取得）
                series = return_series_data(series_data, data_type)
                # Novelsデータ1件（1件のNovelに基づき新たなデータで構築）
                novel = return_one_novel_data(novel_data)
                # Favoriteデータ全件（1件のNovelに基づき新たなデータで構築）
                favorites = generate_original_favorites_object(novel_data, data_type)
                # Commentデータ全件（1件のNovelに基づき新たなデータで構築）
                comments = generate_original_comments_object(novel_data, data_type)
                # render_json 上記で取得したデータを渡してNovelsオブジェクトを生成
                return_one_novel_object_for_render_json(series, novel, favorites, comments)
            # validates 非公開の場合
            elsif !release?(novel_data)
                #render_json JSONデータをレンダリング
                return_unrelease_data()
            end
        end



    #Favorite

        # Favoritesオブジェクト
        def generate_original_favorites_object(data_for_favorites)
            case data_for_favorites[:data_type]
            #! data_for_favorites = Novelデータ1件
            when "series", "NovelTags#show", "NovelSeries#show", "Users#show"
                # Favorite 各Novelsが持つお気に入りのカウント
                count = loop_array_and_get_one_data(data_for_favorites[:novels], "count_favorites")
                # Favoritesの合計値を算出
                return_original_favorites_data(count, data_type)
            #! data_for_favorites = Novelデータ1件
            when "Novels#show"
                # Favoriteデータ（Novelsをお気に入りにしたユーザーのデータ）
                return_original_favorites_data(data_for_favorites, data_type)
            #! data_for_favrites = NovelFavoritesデータ全件
            when "call_user_favorites_series"
                # SeriesのIDを取得（ユーザーがお気に入りしたSeriesのid）
                series_id = return_series_data(data_for_favorites, data_type)
                # Series1件
                series = NovelSeries.find_by(id: series_id)
                # Series1件（新規の構造）を返す
                return generate_original_series_object(series, "Users#show")
            end
        end



    #Comment

        # Commentsオブジェクト生成
        def generate_original_comments_object(novel_data, data_type)
            case data_type
            #! NovelSeriesから取得する場合
            when "NovelSeries#index", "NovelTags#show", "NovelSeries#show", "Users#show"
                #Comment Novelの持つコメント数
                count = generate_object_from_array(novel_data, "call_comments_count")
                #Comment コメント数の合計値を算出
                return_original_comments_data(count, data_type)
            #! Novelから取得する場合
            when "Novels#show"
                # Commentしたユーザーのデータ
                return_original_comments_data(novel_data, data_type)
            end
        end



    #User

        # ユーザーデータ、そのユーザーが登録しているタグ全件、
        # ユーザーの投稿したSeries全件、投稿したSeriesの数
        # お気に入りにしたSeries、お気に入りにしたSeriesの数
        def generate_original_user_page_object(user, data_type)
            #User ユーザーデータ
            @user = return_user_data(user, data_type)
            #UTag そのユーザーが登録しているタグ全件
            @user_tags = generate_object_from_array(user.user_tags, "get_user_tags")
            #Series ユーザーの投稿したSeries全件
            @user_series = generate_object_from_array(user.novel_series, data_type)
            #Favorites ユーザーがお気に入りにしたSeries
            @user_favorites_series = generate_object_from_array(user.novel_favorites, "call_user_favorites_series")
            #! 最終的にレンダリングするためのJSONデータ
            return_users_page_object_for_render_json(@user, @user_tags, @user_series, @user_favorites_series,
            )
        end


end