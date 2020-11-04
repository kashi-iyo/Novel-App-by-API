module ReturnErrorMessagesConcern

    extend ActiveSupport::Concern

    included do
        helper_method :return_not_present_data, :return_unrelease_data, :failed_to_crud_object,
        :already_existing_object, :unauthorized_errors
    end


    #error 誤ったアクセスを行った場合に返す
    def unauthorized_errors(unauthorized_data)
        errors = unauthorized_data[:errors]
        render json: { status: :unauthorized, errors: errors}
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
            errors: "現在この作品は非公開となっています。",
        }
    end

    #error saveしようとしたオブジェクトが不正だった場合に返すレスポンス
    def failed_to_crud_object(new_object)
        render json: {
            status: :unprocessable_entity,
            errors: new_object[:object].errors.full_messages,
        }
    end

    #error 一意でなければならないデータが重複して保存される処理がされた場合
    def already_existing_object(object)
        render json: {
            status: :unprocessable_entity,
            errors: object[:errors]
        }
    end

end