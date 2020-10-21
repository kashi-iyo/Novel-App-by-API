module ReturnEachDataHelper

# 各オブジェクトのデータフォーマット============================================================

    #! NovelSeries1件のデータフォーマット
    def return_series_data(series, data_type)
        case data_type
        when "NovelSeries#index", "NovelSeries#show", "Novels#show", "NovelTags#show"
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

    #! NovelSeriesを全件で取得する場合のNovelSeriesデータフォーマット
    def return_original_series_data(series, novel, tag, data_type)
        case data_type
        when "NovelSeries#index", "NovelTags#show"
            return {
                series: series,
                novels: novel,
                tags: tag,
            }
        end
    end

    #! Novels1件のデータフォーマット
    def return_one_novel_data(series)
        return {
            novel_id: series.id,
            release: series.release,
            novel_title: series.novel_title,
            novel_description: series.novel_description,
            novel_content: series.novel_content,
        }
    end

    #! NovelSeries1件を取得した際に得られるNovelデータ1件のフォーマット
    def return_original_novel_data_in_one_series(novel, favorite, comment, data_type)
        case data_type
        when "NovelSeries#index", "NovelTags#show"
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

    # NovelFavoritesのカウント / Commentsのカウント
    # それぞれの値の合計値を算出するには、一旦generate_object_from_arr()を介す必要がある。
    def items_counter(novel, data_type)
        case data_type
        when "call_favorites_count"
            [favorites_count: novel.novel_favorites.count]
        when "call_comments_count"
            [comments_count: novel.comments.count]
        end
    end


    #! NovelSeriesオブジェクト1件／Novelsオブジェクト1件を取得する際に得られるお気に入りデータ
    def return_original_favorites_data(data_for_favorites, data_type)
        case data_type
            #! NovelSeriesオブジェクトに必要
        when "NovelSeries#index", "NovelTags#show", "NovelSeries#show"
            return data_for_favorites.flatten.sum {|hash| hash[:favorites_count]}
            #! Novelsオブジェクトに必要
        when "Novels#show"
            favorites_count = data_for_favorites.novel_favorites.count
                # NovelFavoritesデータが存在しない場合にはfavorites_idだけ返す
            if data_for_favorites.novel_favorites === []
                return {
                    favorites_count: favorites_count,
                    favorites_id: "",
                }
            else
                # ループ処理によりお気に入りしたユーザーなどを取得
                return {
                    favorites_count: favorites_count,
                    favorites_data: generate_object_from_arr(
                        data_for_favorites.novel_favorites, "call_return_favorites_data"
                    ),
                }
            end
        end
    end

    #! NovelFavorites1件のデータフォーマット
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

    def return_original_comments_data(data_for_comments, data_type)
        case data_type
            #! NovelSeriesから取得する場合
        when "NovelSeries#index", "NovelTags#show", "NovelSeries#show"
            # コメント総の合計値
            data_for_comments.flatten.sum{|hash| hash[:comments_count]}
        # Novelから取得する場合
        when "Novels#show"
            # ループ処理によりコメントを行ったユーザーなどのデータを取得
            return {
                comments_count: data_for_comments.comments.count,
                comments_data: generate_object_from_arr(
                    data_for_comments.comments,
                    "call_return_comments_data"
                ),
            }
        end
    end

    #! Comments1件のデータフォーマット
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

    # NovelTags1件のデータフォーマット
    # UserTags1件のデータフォーマット
    def return_tag_data(tag, tag_type)
        case tag_type
        #! series_index, show, NovelTags#index, show
        when "call_return_tag_data", "NovelTags#show", "other_series_case",
            "NovelTags#index"
            return {
                tag_id: tag.id,
                tag_name: tag.novel_tag_name,
                series_count: tag.novel_series.count,
            }
        # UserTags#index, show
        when "UserTags#index", "UserTags#show"
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

    # Users1件のデータフォーマット
    def return_user_data(user, user_type)
        case user_type
        when "UserTags#show"
            return {
                user_id: user.id,
                nickname: user.nickname,
                profile: user.profile,
            }
        end
    end
# ========================================================================================

end