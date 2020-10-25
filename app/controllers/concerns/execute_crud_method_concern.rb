module ExecuteCrudMethodConcern

    extend ActiveSupport::Concern

    #! 各コントローラのindex/show/editのオブジェクトの取得と、
    #! create/update/destroyを実行するメソッドをここに定義する。
    included do
        helper_method :execute_get_index_object,:execute_get_show_object,:execute_create_and_save_object, :execute_update_object, :execute_destroy_object
    end


    #Read index用のオブジェクトを取得
    def execute_get_index_object(index_data)
        data_type = index_data[:data_type]
        case data_type
        when "series"
            # 配列なのでそこから1件のデータを取得
            one_data = loop_array_and_get_one_series(index_data)
        when "series_tag"
            one_data = loop_array_and_get_one_tag(index_data)
        end
        read_object_to_render(
            object: one_data,
            data_type: data_type,
            crud_type: index_data[:crud_type],
        )
                # → render_json_crud_object_concern.rb
    end

    #Read show用のオブジェクトを取得
    def execute_get_show_object(show_data)
        data_type = show_data[:data_type]
        crud_type = show_data[:crud_type]
        case data_type
        when "series"
            one_data = generate_original_series_object(show_data)
        when "series_tag"
            one_data = generate_original_tag_object(show_data)
        when "novel"
            # one_data = 
        end
        read_object_to_render(
            object: one_data,
            data_type: data_type,
            crud_type: crud_type,
        )
                # → render_json_crud_object_concern.rb
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
    def execute_create_and_save_object(create_data)
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
                    # → render_json_crud_object_concern.rb
        #validates 保存失敗
        else
            return failed_to_crud_object(new_object)
        end
    end

    #Update オブジェクトをUpdate
    def execute_update_object(updated_data)
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
                    # → render_json_crud_object_concern.rb
        #validates 更新失敗
        else
            return failed_to_crud_object(object)
        end
    end

    #Destroy オブジェクトをDestroy
    def execute_destroy_object(object)
        #validates データを削除
        if object.destroy
            destroy_object_to_render()
                    # → render_json_crud_object_concern.rb
        #validates 削除失敗
        else
            return failed_to_crud_object(object)
        end
    end
end