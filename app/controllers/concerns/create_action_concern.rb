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
        @crud_type = create_data[:crud_type]
        @association = create_data[:association_data]
        # check_already_existing_user_data()メソッド：以下で定義
        return if check_already_existing_user_data(
            association: @association,
            data_type: @data_type
        )
        # objectのnew
        # new_object()：以下で定義
        @new_object = new_object(create_data)
        # objectのsave前の処理
        # before_save()：以下で定義
        before_save(
            object: @new_object,
            association: @association,
            data_type: @data_type
        )
        # objectのsave
        # after_save()：以下で定義
        after_save(
            object: @new_object,
            association: @association,
            data_type: @data_type
        )
    end

    # ユーザー：ログイン済みかどうか
    # お気に入り: お気に入り済みかどうか
    # フォロー: フォロー済みかどうか
    # unauthorized_errprs()メソッド：return_error_messages_concern.rb内に定義
    # already_existing_object()メソッド： return_error_messages_concern.rb内に定義
    def check_already_existing_user_data(check)
        @association = check[:association]
        case check[:data_type]
        when "user"
            if logged_in?
                unauthorized_errors(
                    errors: "すでにログインしています。不正なアクセスです。",
                    error_type: "already_login"
                )
            end
        #Favorites お気に入り済みかどうかのチェック
        when "favorites"
            if favorited_by?(@association)
                already_existing_object(errors: "すでにお気に入り済みです。")
            end
        #! Relationship フォロー済みかどうかのチェック
        when "relationship"
            if following?(@association)
                already_existing_object(errors: "すでにフォローしています。")
            end
        end
    end


    # Createオブジェクトをnewする
    def new_object(new_data)
        obj = new_data[:object]
        ass = new_data[:association_data]
        if new_data[:data_type] === "relationship"
            obj.find_or_create_by(follow_id: ass.id)
        else
            obj.new(new_data[:params])
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
        end
    end

    #Create Save後
    # failed_to_crud_object()：return_error_messages_concern.rb内に定義
    # return_created_object()：以下で定義
    # create_and_save_object_to_render()：以下で定義
    def after_save(save_object)
        @new_object = save_object[:object]
        @association = save_object[:association]
        @data_type = save_object[:data_type]
        if @new_object.save
            # React側へ渡したいオブジェクトの形にする
            @created_object = return_created_object(
                object: @new_object,
                association: @association,
                data_type: @data_type
            )
            # JSONとしてレンダリング
            create_and_save_object_to_render(
                object: @created_object,
                data_type: @data_type,
                crud_type: @crud_type
            )
        #error Save失敗
        else
            return failed_to_crud_object(object: @new_object)
        end
    end

    #Create・Saveされたオブジェクトを返す
    # login!()：authentication_features_concern.rb内に定義
    # save_tag()：novel_series.rb内に定義
    def return_created_object(created_object)
        object = created_object[:object]
        data_type = created_object[:data_type]
        case data_type
        when "user"
            login!(object)
            return {
                id: object.id,
                nickname: object.nickname,
            }
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
        when "relationship"
            {}
        end
    end

    #Create・SaveされたオブジェクトをJSONとしてレンダリングする
    def create_and_save_object_to_render(created_data)
        render json: {
            status: :created,
            object: created_data[:object],
            successful: "正常に保存されました。",
            data_type: created_data[:data_type],
            crud_type: created_data[:crud_type]
        }
    end

end