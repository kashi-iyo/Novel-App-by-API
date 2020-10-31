module LoopArrayConcern

    extend ActiveSupport::Concern

    included do
        helper_method :loop_array_and_get_one_series,
        :loop_array_and_get_one_novel,
        :loop_array_and_get_one_favorites,
        :loop_array_and_get_one_tag,
        :loop_array_and_get_one_data_count,
        :loop_array_and_get_one_comment,
        :loop_array_and_get_one_user
    end


    # Series全件をループ処理
    def loop_array_and_get_one_series(series_data)
        object = series_data[:object]
        data_type = series_data[:data_type]
        crud_type = series_data[:crud_type]
        object.map do |series|
            @series = generate_original_series_object(object: series, data_type: data_type, crud_type: crud_type)
                # → generate_original_object_concern.rb
            # 自身の作品の場合
            if authorized?(object: series)
                @series
            else
                # 公開されている場合
                if !!series[:release]
                    @series
                # 非公開の場合
                elsif !series[:release]
                    next
                end
            end
        end
    end

    # Novels全件をループ処理
    def loop_array_and_get_one_novel(novels_data)
        novels_data[:object].map do |novel|
            if !!novel[:release]
                return_novel_data(
                    object: novel,
                    data_type: novels_data[:data_type]
                )
            elsif !novel[:release]
                []
            end
        end
    end

    # Favorites全件をループ処理
    def loop_array_and_get_one_favorites(favorites_data, data_type)
        if favorites_data === []
            [{favorites_id: ""}]
        else
            favorites_data.map do |favorites|
                return_favorites_data(favorites, data_type)
            end
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