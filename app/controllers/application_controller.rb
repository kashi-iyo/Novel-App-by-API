class ApplicationController < ActionController::Base

    skip_before_action :verify_authenticity_token

    # auth: 認証系のメソッドを定義
    # validates: バリデーション系のメソッドを定義
    # render_json: JSONデータを返すメソッドを定義


# auth 認証系==================================================================================
        helper_method :login!, :logged_in?, :logged_in_user, :current_user, :return_session_data

        #! /// ログインさせる
        def login!
            session[:user_id] = @user.id
        end

        #! /// ログインしているかどうかをbool値で返す
        def logged_in?
            !!session[:user_id]
        end

        #! /// ユーザーがログインしていない場合の処理
        def logged_in_user
            unless logged_in?
                render json: {
                    status: :unauthorized,
                    messages: "ログインまたは、新規登録を行ってください。",
                }
            end
        end

        #! /// 現在ログインしているユーザーを返す
        def current_user
            @current_user ||= User.find(session[:user_id]) if session[:user_id]
        end

        #! ユーザーデータを返す
        def return_session_data(user_data, session_type)
            if session_type === "logout"
                reset_session
                render json: { status: 200, logged_out: true }
            else
                render json: { logged_in: true, user: user_data }
            end
        end
# auth ========================================================================================


# validates 認可用メソッド=====================================================================
    helper_method :release?, :authorized?, :handle_unauthorized, :bad_access

    #! 誤ったアクセスを行った場合に返す
    def bad_access(messages, session_type)
        case session_type
        when "login"
            render json: { status: 401, errors: messages}
        when "is_logged_in?"
            render json: { logged_in: false, message: messages }
        end
    end

    #! /// ログイン中のユーザーとdataのユーザーが一致するかをbool値で返す
    def authorized?(data, data_type)
        if data_type === "user"
            data[:id] === current_user.id
        else
            data[:user_id] === current_user.id
        end
    end

    #! /// dataのユーザーとログインユーザーが不一致な場合の処理
    def handle_unauthorized()
        render json: {
            status: :unauthorized,
            messages: "アクセス権限がありません。",
        }
    end

    #! /// releaseが真かどうか確認
    def release?(data)
        !!data[:release] || !data[:release] && authorized?(data)
    end
# validates ==================================================================================


#render_json 各Controllers#index・showにて取得したいデータをJSONとして取得========
    helper_method :read_object_to_render,

    #Read index／showにて取得させたいオブジェクトを
    #render_json JSONとしてレンダリング。
    def read_object_to_render(object, object2, data_type)
        #! return_object_by_data_type(): application_helper.rb
        @object = helpers.return_object_by_data_type(object, object2, data_type)
        render json: {
            status: 200,
            read_object: @object,
            keyword: data_type,
        }
    end

#render_json==================================================================================


#render_json CRUDされたオブジェクトをJSONデータとしてレンダリング=============================
    helper_method :create_and_save_object_to_render,
    :edit_object_to_render,
    :update_object_to_render,
    :destroy_object_to_render

    #Create・Saveされたオブジェクトを
    #render_json JSONデータとしてレンダリングする
    def create_and_save_object_to_render(object, keyword)
        @object =
        case keyword
        when "create_of_novels"
            {
                novel_id: object.id,
                series_id: object.novel_series_id
            }
        when "return_id"
            object.id
        when "Comment_create"
            {
                comment_id: object.id,
                comment_user_id: object.user_id,
                comment_novel_id: object.novel_id,
                content: object.content,
                commenter: object.commenter,
            }
        when "Favorites_create"
            {
                favorites_id: object.id,
                favorites_user_id: object.user_id,
                favorites_novel_id: object.novel_id,
                favoriter: object.favoriter,
            }
        end
        render json: {
            status: :created,
            created_object: @object,
            successful: "正常に保存されました。",
            keyword: keyword,
        }
    end

    #Edit用のオブジェクトを
    #render_json JSONデータとしてレンダリングする
    def edit_object_to_render(object, object2, keyword)
        @object =
        case keyword
        #edit NovelsデータをEditする場合
        when "edit_of_novels"
            {
                novel_id: object.id,
                user_id: object.user_id,
                novel_title: object.novel_title,
                novel_description: object.novel_description,
                novel_content: object.novel_content,
                release: object.release,
            }
        #edit NovelSeriesデータをEditする場合
        #! object2 = series_tags
        when "edit_of_series"
            #Stag Seriesの持つタグを取得
            @tags = helpers.generate_object_from_array(object2, keyword)
            {
                series_id: object.id,
                user_id: object.user_id,
                series_title: object.series_title,
                series_description: object.series_description,
                release: object.release,
                series_tags: @tags
            }
        when "User_edit"
            #Utag Userの持つタグを取得
            @tags = helpers.generate_object_from_array(object2, keyword)
            {
                user_id: object.id,
                nickname: object.nickname,
                profile: object.profile,
                user_tags: @tags,
            }
        end
        # render_json この時点でJSONデータがレンダリングされる
        render json: {
            status: 200,
            object_for_edit: @object,
            keyword: keyword
        }
    end

    #Updateしたオブジェクトを
    #render_json JSONデータとしてレンダリングする
    def update_object_to_render(object, keyword)
        @object =
        case keyword
        when "update_of_novels"
            {
                novel_id: object.id,
                series_id: object.novel_series_id
            }
        when "update_of_series", "User_update"
            object.id
        end
        render json: {
            status: :ok,
            updated_object: @object,
            successful: "編集が完了しました。",
            keyword: keyword
        }
    end

    #Destroy できたら専用のデータを
    #render_json JSONデータとしてレンダリングする
    def destroy_object_to_render()
        render json: { head: :no_content, success: "正常に削除されました。" }
    end

# render_json=================================================================================

# error 不正なデータ取得をしてしまった際のレスポンス========================================
    helper_method :return_not_present_data, :return_unrelease_data, :failed_to_crud_object, :already_existing_favorites

    #render_json データが存在しない場合に返すJSONレスポンス
    def return_not_present_data
        render json: {
            head: :no_content,
            errors: "データが存在しないため、アクセスできません。",
            keyword: "not_present"
        }
    end

    #render_json データが非公開の場合に返すレスポンス
    def return_unrelease_data
        render json: {
            status: :forbidden,
            messages: "現在この作品は非公開となっています。",
            keyword: "unrelease"
        }
    end

    #render_json saveしようとしたオブジェクトが不正だった場合に返すレスポンス
    def failed_to_crud_object(new_object)
        render json: {
            status: :unprocessable_entity,
            errors: new_object.errors.full_messages,
        }
    end

    def already_existing_favorites
        render json: {
            status: :unprocessable_entity,
            errors: "すでにお気に入り済みです。"
        }
    end
# error ====================================================================================
end
