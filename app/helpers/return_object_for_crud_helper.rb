module ReturnObjectForCrudHelper

    #! Reactから送られてくるパラメータを基にデータをCreate・Save・Update、Editする
    #! object = CRUDするオブジェクト
    #! params = パラメータ
    #! association_data = オブジェクトとアソシエーションされたデータ
    #! data_type = どのモデルを扱うか
    #! crud_type = どのCRUDなのか判別
    def pass_object_to_crud(object, params, association_data, data_type, crud_type)
        case data_type
        when "novel2"
            if authorized?(association_data)
                crud_object(object, params, association_data, data_type, crud_type)
            else
                handle_unauthorized(association_data)
            end
        end
        if authorized?(object)
            crud_object(object, params, association_data, data_type, crud_type)
        else
            handle_unauthorized(object)
        end
    end

    #! オブジェクトをCreate, Edit, Update, Destroyするそれぞれのメソッドへ渡す
    def crud_object(object, params, association_data, data_type, crud_type)
        #Create・Save
        if crud_type === "create"
            create_and_save_object(object, association_data, data_type)
        # Edit
        elsif crud_type === "edit"
            get_object_for_edit(object, association_data, data_type)
        # Update
        elsif crud_type === "update"
            update_object(object, params, association_data, data_type)
        # Destroy
        elsif crud_type === "destroy"
            destroy_object(object, data_type)
        end
    end

    #Create オブジェクトをCreate・Save
    def create_and_save_object(new_object, association_data, data_type)
        #  Novelの場合は以下の処理によりユーザーとの関連付けを行う
        if data_type === "novel2"
            new_object.novel_series_id = association_data.id    #! NovelSeriesのID
            new_object.author = association_data.author         #! NovelSeriesの作者
        end
        #validates 保存
        if new_object.save
            #! Novelsオブジェクト
            if data_type === "novel2"
                # render_json この時点でJSONデータがレンダリングされる。（ApplicationControllerにて）
                create_and_save_object_to_render(new_object, "create_of_novels" )
            #! NovelSeriesオブジェクト
            elsif data_type === "series"
                #! NovelSeriesオブジェクトにNovelTagを登録
                new_object.save_tag(association_data)
                # render_json この時点でJSONデータがレンダリングされる。（ApplicationControllerにて）
                create_and_save_object_to_render(new_object, "create_of_series" )
            end
        #validates 保存失敗
        else
            # render_json この時点でJSONデータがレンダリングされる。（ApplicationControllerにて）
            failed_to_crud_object(new_object)
        end
    end

    #Edit Editするためのオブジェクトを取得
    def get_object_for_edit(object, association_data, data_type)
        # NovelデータをEditする場合
        if data_type === "novel"
            # render_json この時点でJSONデータがレンダリングされる。（ApplicationControllerにて）
            edit_object_to_render( object, {}, "edit_of_novels" )
        #! NovelSeriesデータをEditする場合
        elsif data_type ==="series"
            # render_json この時点でJSONデータがレンダリングされる。（ApplicationControllerにて）
            edit_object_to_render( object, association_data, "edit_of_series")
        end
    end

    #Update オブジェクトをUpdate
    def update_object(object, params, association_data, data_type)
        #validates データを更新
        if object.update(params)
            #update NovelSeriesデータをUpdateする場合
            if data_type === "series"
                object.save_tag(association_data)
                # render_json この時点でJSONデータがレンダリングされる
                update_object_to_render(object, "update_of_series" )
            #update NovelsデータをUpdateする場合
            elsif data_type === "novel"
                # render_json この時点でJSONデータがレンダリングされる
                update_object_to_render(object, "update_of_novels" )
            end
        #validates 更新失敗
        else
            # render_json この時点でJSONデータがレンダリングされる
            failed_to_crud_object(object)
        end
    end

    #Destroy オブジェクトをDestroy
    def destroy_object(object, data_type)
        #validates データを削除
        if object.destroy
            if data_type === "series"
                destroy_object_to_render("series")
            elsif data_type === 'novel'
                destroy_object_to_render("novel")
            end
        #validates 削除失敗
        else
            # render_json この時点でJSONデータがレンダリングされる
            failed_to_crud_object(object)
        end
    end

end