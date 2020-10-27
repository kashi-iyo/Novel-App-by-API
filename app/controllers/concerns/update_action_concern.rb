module UpdateActionConcern

    extend ActiveSupport::Concern

    included do
        helper_method :execute_update_object,
        :return_updated_object,
        :render_json_updated_object
    end

    #Update オブジェクトをUpdate
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
                    # → return_executed_crud_object_concern.rb
            render_json_updated_object(
                object: @updated_object,
                data_type: @data_type,
                crud_type: @crud_type
            )
                    # → render_json_crud_object_concern.rb
        else
            return failed_to_crud_object(@new_object)
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
            successful: "編集が完了しました。",
            data_type: updated_data[:data_type],
            crud_type: updated_data[:crud_type]
        }
    end
end