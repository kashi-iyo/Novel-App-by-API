module CreateActionConcern

    extend ActiveSupport::Concern

    included do
        helper_method :execute_create_and_save_object,
        :before_save,
        :return_created_object,
        :create_and_save_object_to_render
    end

    #Create オブジェクトをCreate・Save
    def execute_create_and_save_object(create_data)
        @data_type = create_data[:data_type]
        @association = create_data[:association_data]
        # object.newを行う
        @new_object = create_data[:object].new(create_data[:params])
        before_save(
            object: @new_object,
            association: @association,
            data_type: @data_type
        )
        if @new_object.save
            @created_object = return_created_object(
                object: @new_object,
                association: @association,
                data_type: data_type
            )
                    # → return_executed_crud_object_concern.rb
            create_and_save_object_to_render(
                object: @created_object,
                data_type: @data_type
            )
                    # → render_json_crud_object_concern.rb
        else
            return failed_to_crud_object(@new_object)
        end
    end

    #Create オブジェクトがSaveされる前に実行
    def before_save(before_save_object)
        @before_save_object = before_save_object[:object]
        @association = before_save_object[:association]
        @data_type = before_save_object[:data_type]
        case @data_type
        #Novels ユーザーとの関連付けを行う
        when "novel_for_create"
            @before_save_object.novel_series_id = @association.id
            @before_save_object.author = @association.author
        #Comment Novelとの関連付け
        when "comment"
            @before_save_object.novel_id = @association.id
        #Favorites お気に入り済みかどうかのチェック
        when "favorites"
            if favorited_by?(@association)
                return already_existing_favorites()
                        # → return_error_messages_concern.rb
            end
                # → validates_features_concern.rb
        end
    end

    #Create・Saveされたオブジェクトを返す
    def return_created_object(created_object)
        object = created_object[:object]
        data_type = created_object[:data_type]
        case data_type
        when "user"
            login!
            return object.id
        when"series"
            object.save_tag(created_object[:association])
            return object.id
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

    #Create・SaveされたオブジェクトをJSONとしてレンダリングする
    def create_and_save_object_to_render(created_data)
        render json: {
            status: :created,
            created_object: created_data[:object],
            successful: "正常に保存されました。",
            keyword: created_data[:data_type],
        }
    end

end