module ReturnExecutedCrudObjectConcern
    extend ActiveSupport::Concern

    included do
        helper_method :return_edit_object, :create_and_save_object_to_render, :return_updated_object, :return_index_object, :return_show_object
    end


    #! 新たに生成したNovelSeriesオブジェクト全件を返す
    def return_index_object(index_object)
        object = index_object[:object]
        case index_object[:data_type]
        when "series"
            return {
                series_count: object.count,
                series: object,
            }
        when "series_tag"
            return {
                tags_count: object.count,
                series_tag: object
            }
        end
    end

    def return_show_object(show_object)
        object = show_object[:object]
        case show_object[:data_type]
        when "series", "series_tag"
            return {
                series: object,
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
    #! generate_original_object_helper.rbにて呼び出し
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

    # Userプロフィールページにて扱うオブジェクト
    #! generate_original_object_helper.rbの「#User」にて呼び出し
    def return_users_page_object_for_render_json(user, tag, user_series, user_favorites_series)
        return {
            user: user,
            tags: tag,
            user_series_count: user_series.count,
            user_series: user_series,
            user_favorites_series_count: user_favorites_series.count,
            user_favorites_series: user_favorites_series,
        }
    end


    #Create・Saveされたオブジェクトを
    def return_created_object(created_object)
        object = created_object[:object]
        type = created_object[:data_type]
        case type
        when "user", "series"
            object.id
        when "novel_for_create"
            {
                novel_id: object.id,
                series_id: object.novel_series_id
            }
        when "comment"
            {
                comment_id: object.id,
                comment_user_id: object.user_id,
                comment_novel_id: object.novel_id,
                content: object.content,
                commenter: object.commenter,
            }
        when "favorites"
            {
                favorites_id: object.id,
                favorites_user_id: object.user_id,
                favorites_novel_id: object.novel_id,
                favoriter: object.favoriter,
            }
        end
    end

    # Editしたいオブジェクト
    def return_edit_object(edit_data)
        object = edit_data[:object]
        association = edit_data[:association_data]
        type = edit_data[:data_type]
        case type
        #edit NovelsデータをEditする場合
        when "novel"
            {
                novel_id: object.id,
                user_id: object.user_id,
                novel_title: object.novel_title,
                novel_description: object.novel_description,
                novel_content: object.novel_content,
                release: object.release,
            }
        #edit NovelSeriesデータをEditする場合
        #! association = series_tags
        when "series"
            #Stag Seriesの持つタグを取得
            @tags = generate_object_from_array(association, "Series_edit")
            {
                series_id: object.id,
                user_id: object.user_id,
                series_title: object.series_title,
                series_description: object.series_description,
                release: object.release,
                series_tags: @tags
            }
        when "user"
            #Utag Userの持つタグを取得
            @tags = generate_object_from_array(association, "User_edit")
            {
                user_id: object.id,
                nickname: object.nickname,
                profile: object.profile,
                user_tags: @tags,
            }
        end
    end

    # Updateされたオブジェクト
    def return_updated_object(updated_object)
        object = updated_object[:object]
        type = updated_object[:data_type]
        case type
        when "novel"
            {
                novel_id: object.id,
                series_id: object.novel_series_id
            }
        when "series", "user"
            object.id
        end
    end

end