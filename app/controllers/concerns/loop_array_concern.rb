module LoopArrayConcern

    extend ActiveSupport::Concern

    included do
        helper_method :loop_array_and_get_one_series,
        :loop_array_and_get_one_favorites,
        :loop_array_and_get_one_tag,
        :loop_array_and_get_one_data_count,
        :loop_array_and_get_one_comment,
        :loop_array_and_get_one_user
    end


    # Series全件をループ処理
    def loop_array_and_get_one_series(series_data)
        series_data[:object].map do |series|
            # 公開されている場合
            if !!series[:release]
                generate_original_series_object(
                    object: series,
                    data_type: series_data[:data_type],
                    crud_type: series_data[:crud_type]
                )
                    # → generate_original_object_concern.rb
            # 非公開の場合
            elsif !series[:release]
                {}
            end
        end
    end

    # Favorites全件をループ処理
    def loop_array_and_get_one_favorites(favorites_data, data_type)
        favorites_data.map do |favorites|
            return_favorites_data(favorites, data_type)
        end
    end

    # Comments全件をループ処理
    def loop_array_and_get_one_comment(comment_data, data_type)
        comment_data.map do |comment|
            return_comments_data(comment, data_type)
        end
    end

    # Utag UserTags全件 or
    # Stag SeriesTags全件をループ処理
    def loop_array_and_get_one_tag(tag_data)
        tag_data[:object].map do |tag|
            return_tag_data(tag, tag_data[:data_type])
                # → return_various_data_concern.rb
        end
    end

    # User全件をループ処理
    def loop_array_and_get_one_user(user_data)
        user_data[:object].map do |user|
            return_user_data(
                object: user,
                data_type: user_data[:data_type],
                crud_type: user_data[:crud_type]
            )
        end
    end

    # 渡されたデータの数をループ処理
    def loop_array_and_get_one_data_count(data, data_type)
        data.map do |d|
            items_counter(d, data_type)
                # → return_various_data_concern.rb
        end
    end


end