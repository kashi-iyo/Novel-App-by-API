module ValidatesFeaturesConcern

    extend ActiveSupport::Concern

    # validates 認可用メソッド
    included do
        helper_method :release?, :authorized?, :handle_unauthorized, :bad_access, :return_not_present_data, :return_unrelease_data, :failed_to_crud_object, :already_existing_favorites, :favorited_by?
    end

    #validates ログイン中のユーザーとdataのユーザーが一致するかをbool値で返す
    def authorized?(data, data_type)
        if data_type === "user"
            data[:id] === current_user.id
        elsif data_type === "novel_for_create"
            data[:association_data][:user_id] === current_user.id
        else
            data[:object][:user_id] === current_user.id
        # else
        #     data[:user_id] === current_user.id
        end
    end

    #validates releaseが真かどうか確認
    def release?(data)
        !!data[:release] || !data[:release] && authorized?(data)
    end

    #validates ユーザーがその小説をお気に入りしているかどうかをチェック
    def favorited_by?(novel_data)
        novel_data.novel_favorites.where(user_id: current_user.id).exists?
    end


    #error dataのユーザーとログインユーザーが不一致な場合の処理
    def handle_unauthorized()
        render json: {
            status: :unauthorized,
            messages: "アクセス権限がありません。",
        }
    end

    #error 誤ったアクセスを行った場合に返す
    def bad_access(messages, data_type)
        case data_type
        when "login"
            render json: { status: 401, errors: messages}
        when "is_logged_in?"
            render json: { logged_in: false, message: messages }
        end
    end

    #errorデータが存在しない場合に返すJSONレスポンス
    def return_not_present_data
        render json: {
            head: :no_content,
            errors: "データが存在しないため、アクセスできません。",
            keyword: "not_present"
        }
    end

    #error データが非公開の場合に返すレスポンス
    def return_unrelease_data
        render json: {
            status: :forbidden,
            messages: "現在この作品は非公開となっています。",
            keyword: "unrelease"
        }
    end

    #error saveしようとしたオブジェクトが不正だった場合に返すレスポンス
    def failed_to_crud_object(new_object)
        render json: {
            status: :unprocessable_entity,
            errors: new_object.errors.full_messages,
        }
    end

    #error すでにお気に入りしている場合
    def already_existing_favorites
        render json: {
            status: :unprocessable_entity,
            errors: "すでにお気に入り済みです。"
        }
    end


end