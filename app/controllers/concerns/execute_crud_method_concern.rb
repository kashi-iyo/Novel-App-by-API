module ExecuteCrudMethodConcern

    extend ActiveSupport::Concern

    #! 各コントローラのindex/show/editのオブジェクトの取得と、
    #! create/update/destroyを実行するメソッドをここに定義する。
    included do
        helper_method :return_object_by_data_type, :pass_object_to_crud, :crud_object, :create_and_save_object, :update_object, :destroy_object, :return_index_object
    end


    #validates 認可のチェックを行う
    def pass_object_to_crud(**crud_data)
        if authorized?(crud_data, crud_data[:data_type])
            crud_object(crud_data)
        else
            return handle_unauthorized()
        end
    end

    #! オブジェクトをCreate, Edit, Update, Destroyするそれぞれのメソッドへ渡す
    def crud_object(crud_data)
        case crud_data[:crud_type]
        #Read
        when "index"
            return_index_object(crud_data)
        #Read
        when "show"
        # Create・Save
        when "create"
            create_and_save_object(crud_data)
        # Edit
        when "edit"
            edit_object_to_render(crud_data)
        # Update
        when "update"
            update_object(crud_data)
        # Destroy
        when "destroy"
            destroy_object(object)
        end
    end

    def return_index_object(index_data)
        type = index_data[:data_type]
        case type
        when "series"
            # 配列なのでそこから1件のデータを取得
            one_data = loop_array_and_get_one_data(index_data)
        end
    end

    #! index/show
    def return_object_by_data_type(object, object2, data_type)
        case data_type
        when "NovelSeries#index", "NovelTags#show", "UserTags#show",
                "NovelTags#index", "UserTags#index"
            #! NovelSeries#index, object = NovelSeries.all
            #! NovelTags#index,   object = UserTag.all
            #! UserTags#index,    object = UserTags.all
            #! NovelTags#show,    object = NovelSeries.all  object2 = NovelTag1件
            #! UserTags#show,     object = Users.all,       object2 = UserTag1件
            new_object = generate_object_from_arr(object, data_type)
            case data_type
            when "NovelTags#index","UserTags#index"
                #Utag UserTags全件を返す
                #Stag SeriesTags全件を返す
                return new_object
            when "NovelSeries#index"
                # Series全件（オリジナルのオブジェクト）を返す
                return_all_series_object_for_render_json(new_object, {}, data_type)
            when "UserTags#show", "NovelTags#show"
                #Utag UserTag1件を返す or
                #Stag SeriesTag1件を返す
                tag = return_tag_data(object2, data_type)
                case data_type
                when "UserTags#show"
                    #User tagに関連付けされたUsers全件（オリジナルのオブジェクト）
                    return_users_object_for_render_json(tag, new_object)
                when "NovelTags#show"
                    #Series tagに関連付けされたSeries全件（オリジナルのオブジェクト）を返す
                    return_all_series_object_for_render_json(new_object, tag, data_type)
                end
            end
        #! object = NovelSeries1件
        when "NovelSeries#show"
            # Series1オブジェクト件（Novels全件・コメント合計値・お気に入り合計値などを持つ）を返す
            generate_original_series_object(object, data_type)
        #! object = NovelSeries1件, object2 = Novel1件
        when "Novels#show"
            # Novelsオブジェクト1件（Series1件に紐付けされたオリジナルのオブジェクト）
            generate_original_novel_content_object(object, object2, data_type)
        when "Users#show"
            # Userオブジェクト1件（ユーザーが投稿したSeries/お気に入りしたSeriesなど）
            generate_original_user_page_object(object, data_type)
        end
    end

    #Create オブジェクトをCreate・Save
    def create_and_save_object(create_data)
        type = create_data[:data_type]
        association = create_data[:association_data]
        #! ここでデータを生成する
        new_object = create_data[:object].new(create_data[:params])
        case type
        #Novels ユーザーとの関連付けを行う
        when "novel_for_create"
            new_object.novel_series_id = association.id
            new_object.author = association.author
        #Comment Novelとの関連付け
        when "comment"
            new_object.novel_id = association.id
        when "favorites"
            if favorited_by?(association)
                return already_existing_favorites()
            end
        end
        #validates 保存
        if new_object.save
            #auth ログイン
            login! if type === "user"
            #Stag NovelSeriesオブジェクトにNovelTagを登録
            new_object.save_tag(association) if type === "series"
            #! 保存されたオブジェクトを渡す
            create_and_save_object_to_render(object: new_object, data_type: type)
        #validates 保存失敗
        else
            return failed_to_crud_object(new_object)
        end
    end

    #Update オブジェクトをUpdate
    def update_object(updated_data)
        new_object = updated_data[:object]
        association = updated_data[:association_data]
        #validates データを更新
        if new_object.update(updated_data[:params])
            case data_type
            when "series"
                new_object.save_tag(association)
            when "user"
                object.save_user_tag(association)
            end
            update_object_to_render(updated_object: new_object, data_type: updated_data[:data_type])
        #validates 更新失敗
        else
            return failed_to_crud_object(object)
        end
    end

    #Destroy オブジェクトをDestroy
    def destroy_object(object)
        #validates データを削除
        if object.destroy
            destroy_object_to_render()
        #validates 削除失敗
        else
            return failed_to_crud_object(object)
        end
    end

end