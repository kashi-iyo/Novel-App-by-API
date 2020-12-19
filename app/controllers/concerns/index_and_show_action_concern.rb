module IndexAndShowActionConcern

    extend ActiveSupport::Concern

    included do
        helper_method :execute_get_index_object,
        :return_index_object,
        :execute_get_show_object,
        :return_show_object,
        :render_json_crud_object
    end

    #Read index用のオブジェクトを取得
    # render_json_crud_object()：以下で定義
    # return_index_object()：以下で定義
    def execute_get_index_object(index_data)
        @object = return_index_object(index_data)
        render_json_crud_object(
            status: 200,
            object: @object,
            data_type: index_data[:data_type],
            crud_type: index_data[:crud_type],
        )
    end

    # loop_array_and_get_one_series()：loop_array_concern.rb内に定義
    # loop_array_and_get_one_tag()：loop_array_concern.rb内に定義
    def return_index_object(index_data)
        case index_data[:data_type]
        when "series"
            series_data = loop_array_and_get_one_series(index_data).compact
            return {
                series_count: series_data.count,
                series: series_data
            }
        when "series_tag", "user_tag"
            tags_data = loop_array_and_get_one_tag(index_data)

            return {
                tags_count: tags_data.count,
                tags: tags_data
            }
        end
    end


    #Read show用のオブジェクトを取得
    # return_show_object()：以下で定義
    # render_json_crud_object()：以下で定義
    def execute_get_show_object(show_data)
        @object = return_show_object(show_data)
        render_json_crud_object(
            status: 200,
            object: @object,
            data_type: show_data[:data_type],
            crud_type: show_data[:crud_type],
        )
    end

    # 受け取るデータによってオブジェクトを生成
    def return_show_object(show_data)
        case show_data[:data_type]
        when "series"
            generate_original_series_object(show_data)
                    # → generate_original_object_concern.rb内に定義
        when "series_tag", "user_tag"
            generate_original_tag_object(show_data)
                    # → generate_original_object_concern.rb内に定義
        when "novel"
            generate_original_novel_object(show_data)
                    # → generate_original_object_concern.rb内に定義
        when "user", "followings", "followers"
            generate_original_user_object(show_data)
                    # → generate_original_object_concern.rb内に定義
        end
    end



    #Read index/showにて取得したオブジェクトをJSONとしてレンダリング
    def render_json_crud_object(json_object)
        render json: {
            status: json_object[:status],
            selection: json_object[:selection],
            object: json_object[:object],
            data_type: json_object[:data_type],
            crud_type: json_object[:crud_type]
        }
    end

end