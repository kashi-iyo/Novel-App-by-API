module ReturnGeneratedObjectFromArrayHelper

    #! 配列データを新たなデータ構造に生成し直して取得
    def generate_object_from_array(array, data_type)
        array.map do |data|
            case data_type
            when "NovelSeries#index", "NovelTags#show",  "Users#show"
                #validates NoveSeriesが公開されている場合
                if !!data[:release]
                    # Series（新規の構造）
                    generate_original_series_object(data, data_type)
                #validates NovelSeriesが非公開の場合
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
            when "get_user_tags", "call_return_tag_data", "edit_of_series", "UserTags#index", "NovelTags#index", "User_edit"
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

end