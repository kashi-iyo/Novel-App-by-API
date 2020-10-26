module ReturnErrorMessagesConcern

    extend ActiveSupport::Concern

    included do
        helper_method :return_not_present_data, :return_unrelease_data, :failed_to_crud_object, :already_existing_favorites
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
            errors: new_object[:object].errors.full_messages,
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