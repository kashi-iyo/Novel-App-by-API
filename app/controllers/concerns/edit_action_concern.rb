module EditActionConcern

    extend ActiveSupport::Concern

    included do
        helper_method :edit_object_to_render, :return_edit_object
    end

    #Edit用のオブジェクトをJSONデータとしてレンダリングする
    def edit_object_to_render(edit_data)
        @object = return_edit_object(edit_data)
        render json: {
            status: 200,
            object: @object,
            data_type: edit_data[:data_type],
            crud_type: edit_data[:crud_type]
        }
    end

    # Editしたいオブジェクト
    def return_edit_object(edit_data)
        object = edit_data[:object]
        association = edit_data[:association_data]
        type = edit_data[:data_type]
        case type
        when "novel"
            {
                novel_id: object.id,
                user_id: object.user_id,
                novel_title: object.novel_title,
                novel_description: object.novel_description,
                novel_content: object.novel_content,
                release: object.release,
            }
        when "series"
            #Stag Seriesの持つタグを取得
            @tags = loop_array_and_get_one_tag(
                object: association,
                data_type: "Series_edit"
            )
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
            @tags = loop_array_and_get_one_tag(
                object: association,
                data_type: "User_edit"
            )
            {
                user_id: object.id,
                nickname: object.nickname,
                profile: object.profile,
                user_tags: @tags,
            }
        end
    end



end