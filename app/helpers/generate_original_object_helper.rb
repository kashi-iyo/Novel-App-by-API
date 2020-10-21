module GenerateOriginalObjectHelper

#generate_original_object 
# React側で使用するためのオブジェクトを生成する===========================================

    #! NovelSeries#index, NovelTags#showで扱うオブジェクトを取得
    #! 新たな構造のNovelSeriesオブジェクト1件を生成する。
    # series = NovelSeries1件
    def generate_original_series_object(series, data_type)

        #! 1件のNovelSeriesデータを取得
        @series = return_series_data(series, data_type)
            #! 1件のNovelSeriesが所有するNovelsデータ全件を取得
            @novels = generate_original_novel_object(series, data_type)
            #! 1件のNovelSeriesが所有するNovelTagsデータ全件を取得
            @tags = generate_object_from_arr(series.novel_tags, "call_return_tag_data")

        case data_type
        #! NovelSeries#index, NovelTags#showの場合
        when "NovelSeries#index","NovelTags#show"
            # ここで取得したデータは、return_object_by_data_type()の
            # return_all_series_object_for_render_json()へ渡される。
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


    #! Novels#showで扱うオブジェクトを取得
    #! 新たな構造のNovelsオブジェクト1件を生成する。
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
        # validates 非公開の場合
        elsif !release?(novel_data)
            #render_json JSONデータをレンダリング
            return_unrelease_data()
        end
    end

    #! 新たな構造のNovelsオブジェクト1件を生成する。
    #! （小説データ/お気に入りデータ/コメントデータを持つ）
    # object = novel1件, series1件
    def generate_original_novel_object(object, data_type)
        case data_type
        # ここではobject = series1件
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
        # ここではobject = novel1件
        when "Novels#show"
            return_one_novel_data(object)
        end
    end

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

end