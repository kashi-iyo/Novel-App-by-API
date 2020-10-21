module ReturnEachDataHelper

#! 各オブジェクトのデータフォーマット============================================================

#Series===============================================

    #Series1件のデータフォーマット
    def return_series_data(data_for_series, data_type)
        case data_type
        #! data_for_series = Seriesデータ
        when "NovelSeries#index", "NovelSeries#show", "Novels#show", "NovelTags#show", "Users#show"
            return {
                series_id: data_for_series.id,
                user_id: data_for_series.user_id,
                author: data_for_series.author,
                release: data_for_series.release,
                series_title: data_for_series.series_title,
                series_description: data_for_series.series_description,
            }
        #! data_for_series = Favoritesデータ1件
        when "call_user_favorites_series_id"
            ["novel_series_id", data_for_series.novel.novel_series_id]
        #! data_for_series = お気に入りデータが持つseries_id
        when "call_user_favorites_series_data"
            return NovelSeries.where(id: data_for_series)
        end
    end

    #Seriesを全件で取得する場合のオリジナルのNovelSeriesデータフォーマット
    def return_original_series_data(series, novel, tag, data_type)
        case data_type
        when "NovelSeries#index", "NovelTags#show", "Users#show"
            return {
                series: series,
                novels: novel,
                tags: tag,
            }
        end
    end

#Series===============================================

#Novels===============================================

    #Novels1件のデータフォーマット
    def return_one_novel_data(novel)
        return {
            novel_id: novel.id,
            release: novel.release,
            novel_title: novel.novel_title,
            novel_description: novel.novel_description,
            novel_content: novel.novel_content,
        }
    end

    #Novels1件のオリジナルデータフォーマット（NovelSeries1件に紐付けされた）
    def return_original_novel_data_in_one_series(novel, favorite, comment, data_type)
        case data_type
        when "NovelSeries#index", "NovelTags#show", "Users#show"
            return {
                novels_count: novel,
                favorites_count: favorite,
                comments_count: comment,
            }
        when "NovelSeries#show"
            return {
                novels_count: novel.count,
                favorites_count: favorite,
                comments_count: comment,
                novels: novel,
            }
        end
    end

#Novels===============================================


    #Favoritesのカウント
    #Commentsのカウント
    #! それぞれの値の合計値を算出するには、一旦generate_object_from_arr()を介す必要がある。
    def items_counter(novel, data_type)
        case data_type
        when "call_favorites_count"
            [favorites_count: novel.novel_favorites.count]
        when "call_comments_count"
            [comments_count: novel.comments.count]
        end
    end

#Favorite=============================================

    # Favorite全件のオリジナルデータ
    #! Series1件／Novels1件を取得する際に得られるお気に入りデータ
    def return_original_favorites_data(data_for_favorites, data_type)
        case data_type
        when "NovelSeries#index", "NovelTags#show", "NovelSeries#show"
            # Favorite数の合計値
            return data_for_favorites.flatten.sum {|hash| hash[:favorites_count]}
        when "Novels#show"
            favorites_count = data_for_favorites.novel_favorites.count
                #! NovelFavoritesデータが存在しない場合にはfavorites_idだけ返す
            if data_for_favorites.novel_favorites === []
                return {
                    favorites_count: favorites_count,
                    favorites_id: "",
                }
            else
                return {
                    favorites_count: favorites_count,
                    #Favorite ループ処理によりお気に入りしたユーザーなどを取得
                    favorites_data: generate_object_from_arr(
                        data_for_favorites.novel_favorites, "call_return_favorites_data"
                    ),
                }
            end
        end
    end

    #Favorite1件のデータフォーマット
    def return_favorites_data(favorites, favorites_type)
        case favorites_type
        when "call_return_favorites_data"
            return {
                favorites_id: favorites.id,
                favorites_user_id: favorites.user_id,
                favorites_novel_id: favorites.novel_id,
                favoriter: favorites.favoriter,
            }
        end
    end

#Favorite=============================================

#Comment==============================================

    #Comment全件のオリジナルデータ
    def return_original_comments_data(data_for_comments, data_type)
        case data_type
        when "NovelSeries#index", "NovelTags#show", "NovelSeries#show"
            #Comment コメント総の合計値
            data_for_comments.flatten.sum{|hash| hash[:comments_count]}
        when "Novels#show"
            return {
                comments_count: data_for_comments.comments.count,
                #Comment ループ処理によりコメントを行ったユーザーなどのデータを取得
                comments_data: generate_object_from_arr(
                    data_for_comments.comments,
                    "call_return_comments_data"
                ),
            }
        end
    end

    #Comments1件のデータフォーマット
    def return_comments_data(comment, comment_type)
        case comment_type
        when "call_return_comments_data"
            return {
                comment_id: comment.id,
                comment_user_id: comment.user_id,
                comment_novel_id: comment.novel_id,
                comment_content: comment.content,
                comment_commenter: comment.commenter,
            }
        end
    end

#Comment==============================================

#Stags================================================
#Utags================================================

    #STags SeriesTags1件のデータフォーマット
    #UTags UserTags1件のデータフォーマット
    def return_tag_data(tag, tag_type)
        case tag_type
        when "call_return_tag_data", "NovelTags#show", "NovelTags#index"
            return {
                tag_id: tag.id,
                tag_name: tag.novel_tag_name,
                series_count: tag.novel_series.count,
            }
        when "UserTags#index", "UserTags#show", "get_user_tags"
            return {
                tag_id: tag.id,
                tag_name: tag.user_tag_name,
                count: tag.users.count,
            }
        #Stag ["タグ1", "タグ2"]のような形で取得。(React側では配列として扱いたいため)
        when 'edit_of_series'
            tag.novel_tag_name
        when "ユーザータグ編集"
            # ユーザータグ編集用データ
            tag.user_tag_name
        end
    end

#Stags================================================
#Utags================================================

#User=================================================

    # Users1件のデータフォーマット
    def return_user_data(user, user_type)
        case user_type
        when "UserTags#show", "Users#show"
            return {
                user_id: user.id,
                nickname: user.nickname,
                profile: user.profile,
            }
        end
    end

#User=================================================
# ========================================================================================

end