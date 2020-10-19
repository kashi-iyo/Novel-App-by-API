class ApplicationController < ActionController::Base

    skip_before_action :verify_authenticity_token

    # auth: 認証系のメソッドを定義
    # validates: バリデーション系のメソッドを定義
    # render_json: JSONデータを返すメソッドを定義


# auth 認証系==================================================================================
        helper_method :login!, :logged_in?, :logged_in_user, :current_user

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
# auth ========================================================================================


# validates 認可用メソッド=====================================================================
    helper_method :release?, :authorized?, :handle_unauthorized
    #! /// ログイン中のユーザーとdataのユーザーが一致するかをbool値で返す
    def authorized?(data)
        data[:user_id] === current_user.id
    end

    #! /// dataのユーザーとログインユーザーが不一致な場合の処理
    def handle_unauthorized(data)
        unless authorized?(data)
            render json: {
                status: :unauthorized,
                messages: "アクセス権限がありません。",
            }
        end
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
        #create NovelsデータをCreate・Save
        if keyword === "create_of_novels"
            {
                novel_id: object.id,
                series_id: object.novel_series_id
            }
        #create NovelSeriesデータをCreate ・Save
        elsif keyword === "create_of_series"
            object.id
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
        #edit NovelsデータをEditする場合
        if keyword === "edit_of_novels"
            {
                novel_id: object.id,
                user_id: object.user_id,
                novel_title: object.novel_title,
                novel_description: object.novel_description,
                novel_content: object.novel_content,
                release: object.release,
            }
        #edit NovelSeriesデータをEditする場合
        elsif keyword === "edit_of_series"
            @tags = helpers.generate_object_from_arr(object2,"edit_of_series")
            {
                series_id: object.id,
                user_id: object.user_id,
                series_title: object.series_title,
                series_description: object.series_description,
                release: object.release,
                series_tags: @tags
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
        #update NovelsデータをUpdateする場合
        if keyword === "update_of_novels"
            {
                novel_id: object.id,
                series_id: object.novel_series_id
            }
        #update NovelSeriesデータをUpdateする場合
        elsif keyword === "update_of_series"
            object.id
        end
        # render_json この時点でJSONデータがレンダリングされる
        render json: {
            status: :ok,
            updated_object: @object,
            successful: "編集が完了しました。",
            keyword: keyword
        }
    end

    #Destroy できたら専用のデータを
    #render_json JSONデータとしてレンダリングする
    def destroy_object_to_render(data_type)
        if data_type === "novel" || data_type === "series"
            render json: { head: :no_content, success: "正常に削除されました。" }
        end
    end

# render_json=================================================================================

# object 新たにオブジェクトを生成するメソッド================================================
    helper_method :remake_arr_to_new_object

    #! /// 新たに作成したいオブジェクトを返す。ここでは"配列"データを各々のオブジェクト化するメソッドへ渡している。
    #! /// UserTagsコントローラ, NovelTagsコントローラ, series_and_novel_json_to_render()にて使用
    def remake_arr_to_new_object(data, data_type)
        data.map do |d|
            # tags UserTagsオブジェクト全件返す
            if data_type === "user_tag"
                return_new_tag_object(d, "user_tag")
            # tags NovelTagsオブジェクト返す
            elsif data_type ==="series_tag"
                return_new_tag_object(d, "series_tag")
            # Usersオブジェクトを返す
            elsif data_type === "user"
                return_new_user_object(d)
            # NovelSeries編集用のNovelTagsオブジェクトを返す
            elsif data_type === "edit_of_series"
                return_new_tag_object(d, "edit_of_series")
            end
        end
    end
# ==================================================================================

# tags タグ系機能==========================================================================
    # helper_method :return_new_tag_object

    # #! /// NovelTags/UserTagsの新たなオブジェクトを生成する
    # #! /// 主にremake_arr_to_new_object()にてループ処理されたデータをここでオブジェクト化する。
    # def return_new_tag_object(tag, tags_type)
    #     # UserTags
    #     if tags_type === "user_tag"
    #         return {
    #             tag_id: tag.id,
    #             tag_name: tag.user_tag_name,
    #             count: tag.users.count,
    #         }
    #     # NovelTags
    #     elsif tags_type ==="series_tag"
    #         return {
    #             tag_id: tag.id,
    #             tag_name: tag.novel_tag_name,
    #             count: tag.novel_series.count,
    #         }
    #     # NovelSeries編集用のNovelTags
    #     # ["タグ1", "タグ2"]のような形で取得
    #     elsif tags_type === 'edit_of_series'
    #         tag.novel_tag_name
    #     end
    # end
# tags ====================================================================================

# error 不正なデータ取得をしてしまった際のレスポンス========================================
    helper_method :return_not_present_data, :return_unrelease_data, :failed_to_crud_object

    #render_json データが存在しない場合に返すJSONレスポンス
    def return_not_present_data
        render json: {
            head: :no_content,
            errors: "作品が存在しないため、アクセスできません。",
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
# error ====================================================================================
end
