module ApplicationHelper

    include ReturnGeneratedObjectFromArrayHelper
    include ReturnEachDataHelper
    include GenerateOriginalObjectHelper
    include ReturnObjectForCrudHelper
    include ReturnObjectForRenderJsonHelper

#! React側で使用するために、data_typeに基づいて取得したデータをオリジナルのオブジェクトに構築し直す。
#! 構築したオブジェクトは、Applicationコントローラのメソッドへ渡しJSONデータをレンダリングする。


    def return_object_by_data_type(object, object2, data_type)
        case data_type
        when "NovelSeries#index", "NovelTags#show", "UserTags#show",
                "NovelTags#index", "UserTags#index"
            #! NovelSeries#index, object = NovelSeries.all
            #! NovelTags#index,   object = UserTag.all
            #! UserTags#index,    object = UserTags.all
            #! NovelTags#show,    object = NovelSeries.all  object2 = NovelTag1件
            #! UserTags#show,     object = Users.all,       object2 = UserTag1件
            new_object = generate_object_from_arr(object, data_type)
            case data_type
            when "NovelTags#index","UserTags#index"
                #Utag UserTags全件を返す
                #Stag SeriesTags全件を返す
                return new_object
            when "NovelSeries#index"
                # Series全件（オリジナルのオブジェクト）を返す
                return_all_series_object_for_render_json(new_object, {}, data_type)
            when "UserTags#show", "NovelTags#show"
                #Utag UserTag1件を返す or
                #Stag SeriesTag1件を返す
                tag = return_tag_data(object2, data_type)
                case data_type
                when "UserTags#show"
                    #User tagに関連付けされたUsers全件（オリジナルのオブジェクト）
                    return_users_object_for_render_json(tag, new_object)
                when "NovelTags#show"
                    #Series tagに関連付けされたSeries全件（オリジナルのオブジェクト）を返す
                    return_all_series_object_for_render_json(new_object, tag, data_type)
                end
            end
        #! object = NovelSeries1件
        when "NovelSeries#show"
            # Series1オブジェクト件（Novels全件・コメント合計値・お気に入り合計値などを持つ）を返す
            generate_original_series_object(object, data_type)
        #! object = NovelSeries1件, object2 = Novel1件
        when "Novels#show"
            # Novelsオブジェクト1件（Series1件に紐付けされたオリジナルのオブジェクト）
            generate_original_novel_content_object(object, object2, data_type)
        when "Users#show"
            # Userオブジェクト1件（ユーザーが投稿したSeries/お気に入りしたSeriesなど）
            generate_original_user_page_object(object, data_type)
        end
    end

end
