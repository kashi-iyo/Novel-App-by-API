module RenderJsonCrudObjectConcern

    extend ActiveSupport::Concern

    included do
        helper_method :create_and_save_object_to_render,
        :edit_object_to_render,
        :update_object_to_render,
        :destroy_object_to_render,:read_object_to_render
    end


    #Read index／showにて取得させたいオブジェクトを
    def read_object_to_render(read_object)
            case read_object[:crud_type]
            when "index"
                @object = return_index_object(read_object)
                    # → return_executed_crud_object_concern.rb
            when "show"
                @object = read_object
                    # → return_executed_crud_object_concern.rb
            end
        render json: {
            status: 200,
            read_object: @object,
            data_type: read_object[:data_type],
            crud_type: read_object[:crud_type]
        }
    end

    #Create・Saveされたオブジェクトを
    #render_json JSONデータとしてレンダリングする
    def create_and_save_object_to_render(created_data)
        @object = return_created_object(created_data)
            # → return_executed_crud_object_concern.rb
        render json: {
            status: :created,
            created_object: @object,
            successful: "正常に保存されました。",
            keyword: created_data[:data_type],
        }
    end

    #Edit用のオブジェクトを
    #render_json JSONデータとしてレンダリングする
    def edit_object_to_render(edit_data)
        @object = return_edit_object(edit_data)
            # → return_executed_crud_object_concern.rb
        render json: {
            status: 200,
            object_for_edit: @object,
            keyword: edit_data[:data_type]
        }
    end

    #Updateしたオブジェクトを
    #render_json JSONデータとしてレンダリングする
    def update_object_to_render(updated_data)
        @object = return_updated_object(updated_data)
            # → return_executed_crud_object_concern.rb
        render json: {
            status: :ok,
            updated_object: @object,
            successful: "編集が完了しました。",
            keyword: updated_data[:data_type]
        }
    end

    #Destroy できたら専用のデータを
    #render_json JSONデータとしてレンダリングする
    def destroy_object_to_render()
        render json: { head: :no_content, success: "正常に削除されました。" }
    end

end