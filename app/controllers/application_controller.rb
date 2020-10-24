class ApplicationController < ActionController::Base

    skip_before_action :verify_authenticity_token


    # 渡す配列データをtypeに応じた繰り返し処理してくれるメソッド
    include LoopArrayConcern
    # 各モデルのデータを適切な形式に整理したデータ
    include ReturnVariousDataConcern
    # index / showで取得したいオリジナルのオブジェクトを生成する
    include GenerateOriginalObjectConcern
    # CRUDを実行するメソッド
    include ExecuteCrudMethodConcern
    # CRUDが実行された後のオブジェクトを返す
    include ReturnExecutedCrudObjectConcern
    # 認証系の機能
    include AuthenticationFeaturesConcern
    # 認可系の処理を行う
    include ValidatesFeaturesConcern
    # エラーメッセージJSONデータでレンダリング
    include ReturnErrorMessagesConcern
    # index/show/create/edit/udpate/destroy処理後のオブジェクトをJSONとしてレンダリングする
    include RenderJsonCrudObjectConcern

    #! 各コントローラのindex/show/editのオブジェクトの取得と、
    #! create/update/destroyを実行するメソッドをここに定義する。

    #validates 認可のチェックを行う
    def pass_object_to_crud(**crud_data)
        if authorized?(crud_data)
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
            execute_get_index_object(crud_data)
        #Read
        when "show"
            execute_get_show_object(crud_data)
        # Create・Save
        when "create"
            execute_create_and_save_object(crud_data)
        # Edit
        when "edit"
            edit_object_to_render(crud_data)
        # Update
        when "update"
            execute_update_object(crud_data)
        # Destroy
        when "destroy"
            execute_destroy_object(crud_data[:object])
        end
    end
            # →execute_crud_method_concern.rb


end
