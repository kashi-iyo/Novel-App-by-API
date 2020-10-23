module ReturnDoneCrudObjectConcern
    extend ActiveSupport::Concern

    included do
        helper_method :return_edit_object, :create_and_save_object_to_render
    end

    #Create・Saveされたオブジェクトを
    #render_json JSONデータとしてレンダリングする
    def return_created_object(created_data)
        object = created_data[:object]
        type = created_data[:data_type]
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

    # Editオブジェクト
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

    def return_updated_object(updated_data)
        object = updated_data[:object]
        type = updated_data[:data_type]
        case type
        when "update_of_novels"
            {
                novel_id: object.id,
                series_id: object.novel_series_id
            }
        when "update_of_series", "User_update"
            object.id
        end
    end

end