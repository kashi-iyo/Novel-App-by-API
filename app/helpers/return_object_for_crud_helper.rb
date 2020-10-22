module ReturnObjectForCrudHelper

    #! Reactから送られてくるパラメータを基にデータをCreate・Save・Update、Editする
    #! object = CRUDするオブジェクト
    #! params = パラメータ
    #! association_data = オブジェクトとアソシエーションされたデータ
    #! data_type = どのモデルを扱うか
    #! crud_type = どのCRUDなのか判別
    def pass_object_to_crud(object, params, association_data, data_type, crud_type)
        # Novelsの作成の場合
        if data_type === "novel2"
            if authorized?(association_data, data_type)
                crud_object(object, params, association_data, data_type, crud_type)
            else
                handle_unauthorized()
            end
        #! それ以外
        else
            if authorized?(object, data_type)
                crud_object(object, params, association_data, data_type, crud_type)
            else
                handle_unauthorized()
            end
        end
    end

    #! オブジェクトをCreate, Edit, Update, Destroyするそれぞれのメソッドへ渡す
    def crud_object(object, params, association_data, data_type, crud_type)
        case crud_type
        # Create・Save
        when "create"
            create_and_save_object(object, association_data, data_type)
        # Edit
        when "edit"
            get_object_for_edit(object, association_data, data_type)
        # Update
        when "update"
            update_object(object, params, association_data, data_type)
        # Destroy
        when "destroy"
            destroy_object(object)
        end
    end

    #Create オブジェクトをCreate・Save
    def create_and_save_object(new_object, association_data, data_type)
        case data_type
        #! Novel/Commentの場合は以下の処理によりユーザーとの関連付けを行う
        when "novel2"
            #! NovelSeriesのID
            new_object.novel_series_id = association_data.id
            #! NovelSeriesの作者
            new_object.author = association_data.author
        when "comment"
            #! お気に入りした対象のNovelsのID
            new_object.novel_id = association_data.id
        end
        #validates 保存
        if new_object.save
            case data_type
            when "user"
                login!
                create_and_save_object_to_render(new_object, "return_id" )
            when "novel2"
                create_and_save_object_to_render(new_object, "create_of_novels" )
            when "series"
                #! NovelSeriesオブジェクトにNovelTagを登録
                new_object.save_tag(association_data)
                create_and_save_object_to_render(new_object, "return_id" )
            when "comment"
                create_and_save_object_to_render(new_object, "Comment_create")
            when "favorites"
                create_and_save_object_to_render(new_object, "Favorites_create")
            end
        #validates 保存失敗
        else
            failed_to_crud_object(new_object)
        end
    end

    #Edit Editするためのオブジェクトを取得
    def get_object_for_edit(object, association_data, data_type)
        case data_type
        #! NovelデータをEditする場合
        when "novel"
            # render_json この時点でJSONデータがレンダリングされる。（ApplicationControllerにて）
            edit_object_to_render( object, {}, "edit_of_novels" )
        #! NovelSeriesをEditする場合
        when "series"
            # render_json この時点でJSONデータがレンダリングされる。（ApplicationControllerにて）
            edit_object_to_render( object, association_data, "edit_of_series")
        #! UserデータをEditする場合
        when "user"
            edit_object_to_render( object, association_data, "User_edit")
        end
    end

    #Update オブジェクトをUpdate
    def update_object(object, params, association_data, data_type)
        #validates データを更新
        if object.update(params)
            case data_type
            when "series"
                object.save_tag(association_data)
                update_object_to_render(object, "update_of_series" )
            when "novel"
                update_object_to_render(object, "update_of_novels" )
            when "user"
                object.save_user_tag(association_data)
                update_object_to_render(object, "User_update" )
            end
        #validates 更新失敗
        else
            # render_json この時点でJSONデータがレンダリングされる
            failed_to_crud_object(object)
        end
    end

    #Destroy オブジェクトをDestroy
    def destroy_object(object)
        #validates データを削除
        if object.destroy
            destroy_object_to_render()
        #validates 削除失敗
        else
            # render_json この時点でJSONデータがレンダリングされる
            failed_to_crud_object(object)
        end
    end

end