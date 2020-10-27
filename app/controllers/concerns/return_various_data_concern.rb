module ReturnVariousDataConcern

    extend ActiveSupport::Concern

#! 各モデルのデータフォーマット（適切な形式に修正）
    included do
        helper_method :items_counter,
        :return_favorites_data,
        :return_comments_data,
        :return_tag_data,
        :return_user_data
    end


    #! それぞれのデータをカウントする

        #Favoritesのカウント
        #Commentsのカウント
        def items_counter(novel, data_type)
            case data_type
            when "call_favorites_count"
                [favorites_count: novel.novel_favorites.count]
            when "call_comments_count"
                [comments_count: novel.comments.count]
            end
        end

    #Favorite


        #Favorite1件のデータフォーマット
        def return_favorites_data(favorites, favorites_type)
            case favorites_type
            when "novel"
                return {
                    favorites_id: favorites.id,
                    favorites_user_id: favorites.user_id,
                    favorites_novel_id: favorites.novel_id,
                    favoriter: favorites.favoriter,
                }
            when "user"
                favorites.novel.novel_series
            end
        end




    #Comment

        #Comments1件のデータフォーマット
        def return_comments_data(comment, comment_type)
            case comment_type
            when "novel"
                return {
                    comment_id: comment.id,
                    comment_user_id: comment.user_id,
                    comment_novel_id: comment.novel_id,
                    comment_content: comment.content,
                    comment_commenter: comment.commenter,
                }
            end
        end



    #Stags（SeriesTags）
    #Utags（UserTags）

        #STags SeriesTags1件のデータフォーマット
        #UTags UserTags1件のデータフォーマット
        def return_tag_data(tag, tag_type)
            case tag_type
            when "series", "series_tag"
                return {
                    tag_id: tag.id,
                    tag_name: tag.novel_tag_name,
                    has_data_count: tag.novel_series.count,
                }
            when "user", "user_tag"
                return {
                    tag_id: tag.id,
                    tag_name: tag.user_tag_name,
                    has_data_count: tag.users.count,
                }
            #Stag SeriesTag編集用データ ["タグ1", "タグ2"]のような形で取得。(React側では配列として扱いたいため)
            when 'Series_edit'
                tag.novel_tag_name
            #Utag UserTag編集用データ
            when "User_edit"
                tag.user_tag_name
            end
        end



    #User

        # Users1件のデータフォーマット
        def return_user_data(user_data)
            @user = user_data[:object]
            case user_data[:data_type]
            when "user"
                return {
                    user_id: @user.id,
                    nickname: @user.nickname,
                    profile: @user.profile,
                }
            when "user_tag"
                return {
                    user_id: @user.id,
                    nickname: @user.nickname,
                    profile: @user.profile,
                    tag: @user.user_tags,
                }
            end
        end



end