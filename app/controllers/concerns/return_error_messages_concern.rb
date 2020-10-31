module ReturnErrorMessagesConcern

    extend ActiveSupport::Concern

    included do
        helper_method :return_not_present_data, :return_unrelease_data, :failed_to_crud_object,
        :already_existing_object
    end

    #error dataのユーザーとログインユーザーが不一致な場合の処理
    def handle_unauthorized()
        render json: {
            status: :unauthorized,
            messages: "アクセス権限がありません。",
        }
    end

    #error 誤ったアクセスを行った場合に返す
    def bad_access(access_data)
        message = access_data[:message]
        action = access_data[:action]
        case action
        when "login", "logout", "current_user"
            render json: { status: :unauthorized, errors: message}
        when "is_logged_in?"
            render json: { logged_in: false, message: message}
        end
    end

    #errorデータが存在しない場合に返すJSONレスポンス
    def return_not_present_data(data_type)
        case data_type
        when "relationship", "user"
            target = "ユーザー"
        when "novel"
            target = "小説"
        when "series"
            target = "作品"
        when "comment"
            target = "コメント"
        when "favorite"
            target = "お気に入りデータ"
        when "tag"
            target = "タグ"
        end
        render json: {
            head: :no_content,
            errors: "対象の#{target}が存在しません。",
        }
    end

    #error データが非公開の場合に返すレスポンス
    def return_unrelease_data
        render json: {
            status: :forbidden,
            messages: "現在この作品は非公開となっています。",
        }
    end

    #error saveしようとしたオブジェクトが不正だった場合に返すレスポンス
    def failed_to_crud_object(new_object)
        render json: {
            status: :unprocessable_entity,
            errors: new_object[:object].errors.full_messages,
        }
    end

    #error すでにお気に入りしている場合
    def already_existing_object(object)
        render json: {
            status: :unprocessable_entity,
            errors: object[:errors]
        }
    end

end