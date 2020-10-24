module LoopArrayConcern

    extend ActiveSupport::Concern

    included do
        helper_method :loop_array_and_get_one_series, :loop_array_and_get_one_tag, :loop_array_and_get_one_data_count
    end

    #! 配列データを新たなデータ構造に生成し直して取得
    def loop_array_and_get_one_data(array, data_type)
        array.map do |data|
            case data_type
            when "series", "NovelTags#show",  "Users#show"
                # 公開されている場合
                if !!data[:release]
                    # Series 1つのSeriesを渡して、データを新たな形式へ造り変える
                    generate_original_series_object(data, data_type)
                        # → generate_original_object_concern.rb
                # 非公開の場合
                elsif !data[:release]
                    {}
                end
            when "call_favorites_count", "call_comments_count"
                # Favoritesをカウントしたデータ or
                # Commentsをカウントしたデータ
                items_counter(data, data_type)
            when "favorites_count", "call_user_favorites_series"
                # Favorite（新規の構造）
                generate_original_favorites_object(data, data_type)
            when "call_return_favorites_data"
                # Favorite（Favoritesモデルの元の構造）を返す
                return_favorites_data(data, data_type)
            when "comments_count", "comments_in_novel"
                # Commentsオブジェクトを返す
                generate_original_comments_object(data, data_type)
            when "call_return_comments_data"
                # Comment（Commentsモデルの元の構造）を返す
                return_comments_data(data, data_type)
            when "get_user_tags", "get_series_tags", "Series_edit", "UserTags#index", "NovelTags#index", "User_edit"
                #UTags UserTagsオブジェクト or
                #STags SeriesTagsオブジェクトを返す
                return_tag_data(data, data_type)
            when "UserTags#show"
                # Userオブジェクトを返す
                return_user_data(data, data_type)
            when "call_user_favorites_series_data"
                # Series全件を返す（ユーザーがお気に入りにした）
                return_series_data(data, data_type)
            end
        end
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

    # Utag UserTags全件 or
    # Stag SeriesTags全件をループ処理
    def loop_array_and_get_one_tag(tag_data)
        tag_data[:object].map do |tag|
            return_tag_data(tag, tag_data[:data_type])
                    # → return_various_data_concern.rb
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