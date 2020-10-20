module ReturnObjectForRenderJsonHelper


# Applicationコントローラへ渡すオブジェクト===============================================

        #! 新たに生成したNovelSeriesオブジェクト全件を返す
        def return_all_series_object_for_render_json(series, tag, data_type)
            case data_type
            when "NovelSeries#index"
                return {
                    series_count: series.count,
                    all_series: series,
                }
            when "NovelTags#show"
                return {
                    tag: tag,
                    series_count: series.count,
                    all_series: series,
                }
            end
        end

        #! 新たに生成したNovelSeriesオブジェクト1件を返す
        def return_one_series_object_for_render_json(series, novel, tag)
            return {
                series: series,
                novels: novel,
                tags: tag,
            }
        end

        #! 新たに生成したNovelsオブジェクト1件を返す
        # generate_original_novel_content_object()にて呼び出し→Applicationコントローラへ送信
        def return_one_novel_object_for_render_json(series, novel, favorite, comment)
            return {
                series: series,
                novel: novel,
                favorites: favorite,
                comments: comment,
            }
        end

        #! 新たに生成したタグに関連付けされたUsersオブジェクト全件を返す
        def return_users_object_for_render_json(tag, users)
            return {
                tag: tag,
                users_count: users.count,
                users: users,
            }
        end
# =================================================================================================

end