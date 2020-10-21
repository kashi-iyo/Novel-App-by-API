module ReturnGeneratedObjectFromArray

    # 配列データを新たなデータ構造に生成し直して取得
    def generate_object_from_arr(array, data_type)
        array.map do |data|
            case data_type
            #! NovelSeriesオブジェクト全件を返す
            when "NovelSeries#index", "NovelTags#show"
                #validates シリーズが公開されている場合。ここではrelease?()メソッドは使用しない
                if !!data[:release]
                    generate_original_series_object(data, data_type)
                #validates シリーズが非公開の場合
                elsif !data[:release]
                    {}
                end
            # NovelFavorites / Commentsをカウントしたデータを返す
            when "call_favorites_count", "call_comments_count"
                items_counter(data, data_type)
            # NovelFavoritesオブジェクトを返す
            when "favorites_count"
                generate_original_favorites_object(data, data_type)
            #! Novelsオブジェクトをお気に入りしたユーザーを返す
            when "call_return_favorites_data"
                return_favorites_data(data, data_type)
            # Commentsオブジェクトを返す
            when "comments_count", "comments_in_novel"
                generate_original_comments_object(data, data_type)
            when "call_return_comments_data"
                return_comments_data(data, data_type)
            # UserTags / NovelTagsオブジェクトを返す
            when "call_return_tag_data", "edit_of_series", "UserTags#index", "NovelTags#index"
                return_tag_data(data, data_type)
            #! Novelsオブジェクトを返す
            when "UserTags#show"
                return_user_data(data, data_type)
            end
        end
    end

end