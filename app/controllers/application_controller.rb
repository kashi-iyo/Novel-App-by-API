class ApplicationController < ActionController::Base

    skip_before_action :verify_authenticity_token


    # 各Controllerのindex/show用のオブジェクトを取得する
    include IndexAndShowActionConcern
    # 渡す配列データをtypeに応じた繰り返し処理してくれるメソッド
    include LoopArrayConcern
    # 各モデルのデータを適切な形式に整理したデータ
    include ReturnVariousDataConcern
    # index / showで取得したいオリジナルのオブジェクトを生成する
    include GenerateOriginalObjectConcern

    # 各ControllerのCreateを実行する
    include CreateActionConcern
    # 各ControllerのEdit用のオブジェクト取得する
    include EditActionConcern
    # 各ControllerのUpdateを実行する
    include UpdateActionConcern
    # 各ControllerのDestroyを実行する
    include DestroyActionConcern
    # select検索されたオブジェクトを取得する
    include SelectedActionConcern

    # SessionsControllerの処理を実行する
    include SessionConcern

    # 認証系の機能
    include AuthenticationFeaturesConcern
    # 認可系の処理を行う
    include ValidatesFeaturesConcern
    # エラーメッセージJSONデータでレンダリング
    include ReturnErrorMessagesConcern


    #validates 認可のチェックを行う
    def pass_object_to_crud(crud_data)
        if authorized?(crud_data)
            crud_object(crud_data)
        else
            data_type = crud_data[:data_type]
            case data_type
            when "relationship"
                return unauthorized_errors(errors: "自分自身をフォローすることは出来ません。", error_type: "follow_myselfy")
            end
            return unauthorized_errors(errors: "アクセス権限がありません", error_type: data_type)
        end
    end

    #! オブジェクトをIndex, Show, Create, Edit, Update, Destroyするそれぞれのメソッドへ渡す
    def crud_object(crud_data)
        case crud_data[:crud_type]
        #Read
        when "index"
            execute_get_index_object(crud_data)
                # →index_and_show_action_concern.rb
        #Read
        when "show"
            execute_get_show_object(crud_data)
                # →index_and_show_action_concern.rb
        # Create・Save
        when "create"
            execute_create_and_save_object(crud_data)
                # →create_action_concern.rb
        # Edit
        when "edit"
            edit_object_to_render(crud_data)
                # →edit_action_concern.rb
        # Update
        when "update"
            execute_update_object(crud_data)
                # →update_action_concern.rb
        # Destroy
        when "destroy"
            execute_destroy_object(crud_data)
                # →destroy_action_concern.rb
        # select
        when "selected"
            execute_selected_object(crud_data)
        end
    end


end
