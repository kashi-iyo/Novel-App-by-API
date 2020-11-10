module SelectedActionConcern

    extend ActiveSupport::Concern

    included do
        helper_method :execute_selected_object,
        :render_json_selected_object
    end

    # 指定されたselectタグに基づいてオブジェクトを返す
    def execute_selected_object(selected_data)
        @object = return_selected_object(selected_data)
        render_json_selected_object(
            status: 200,
            object: @object,
            data_type: selected_data[:data_type],
            crud_type: selected_data[:crud_type],
        )
    end

    def return_selected_object(selected_data)
        selection = selected_data[:selection]
        case selected_data[:data_type]
        when "series"
            series_data = loop_array_and_get_one_series(selected_data).compact
            return {
                selected_value: set_selected_value(selection),
                series_count: series_data.count,
                series: sorting_series_by_select(
                    object: series_data, selection: selection
                ),
                    # → loop_array_concern.rb
            }
        when "series_tag"
            series_data = generate_original_tag_object(selected_data)
            return {
                selected_value: set_selected_value(selection),
                tag: series_data[:tag],
                series: sorting_series_by_select(
                    object: series_data[:series], selection: selection
                ),
            }
        end
    end

    # selectの値を返す
    def set_selected_value(selection)
        case selection
        when "new"
            "新着順"
        when "old"
            "投稿が古い順"
        when "more_favo"
            "お気に入りが多い順"
        when "less_favo"
            "お気に入りが少ない順"
        when "more_comment"
            "コメントが多い順"
        when "less_comment"
            "コメントが少ない順"
        end
    end

    def render_json_selected_object(json_object)
        render json: {
            status: json_object[:status],
            data_type: json_object[:data_type],
            crud_type: json_object[:crud_type],
            object: json_object[:object],
        }
    end

end