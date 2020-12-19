module UpdateActionConcern

    extend ActiveSupport::Concern

    included do
        helper_method :execute_update_object,
        :return_updated_object,
        :render_json_updated_object
    end

    #Update オブジェクトをUpdate
    # save_tag()：models/novel_series.rb内に定義
    # save_user_tag()：models/user.rb内に定義
    # failed_to_crud_object()：return_error_messages_concern.rb内に定義
    def execute_update_object(updated_data)
        @new_object = updated_data[:object]
        @data_type = updated_data[:data_type]
        @crud_type = updated_data[:crud_type]
        @association = updated_data[:association_data]
        if @new_object.update(updated_data[:params])
            case @data_type
            when "series"
                @new_object.save_tag(@association)
            when "user"
                @new_object.save_user_tag(@association)
            end
            @updated_object = return_updated_object(
                object: @new_object,
                data_type: @data_type
            )
            render_json_updated_object(
                object: @updated_object,
                data_type: @data_type,
                crud_type: @crud_type
            )
        else
            return failed_to_crud_object(object: @new_object)
        end
    end

    # Updateされたオブジェクト
    def return_updated_object(updated_object)
        object = updated_object[:object]
        type = updated_object[:data_type]
        case type
        when "novel"
            {
                novel_id: object.id,
                series_id: object.novel_series_id
            }
        when "series", "user"
            object.id
        end
    end

    #UpdateしたオブジェクトをJSONとしてレンダリングする
    def render_json_updated_object(updated_data)
        render json: {
            status: :ok,
            object: updated_data[:object],
            successful: "正常に編集が完了しました。",
            data_type: updated_data[:data_type],
            crud_type: updated_data[:crud_type]
        }
    end
end