module DestroyActionConcern

    extend ActiveSupport::Concern

    included do
        helper_method :execute_destroy_object,
        :render_json_destroyed_object
    end


    #Destroy オブジェクトをDestroy
    # failed_to_crud_object()：return_error_messages_concern.rb内に定義
    def execute_destroy_object(object)
        if object[:object].destroy
            render_json_destroyed_object(object)
        else
            return failed_to_crud_object(object)
        end
    end

    #Destroy できたら専用のデータをJSONとしてレンダリングする
    def render_json_destroyed_object(destroyed_data)
        render json: {
            head: :no_content,
            successful: "正常に削除されました。",
            crud_type: destroyed_data[:crud_type]
        }
    end

end