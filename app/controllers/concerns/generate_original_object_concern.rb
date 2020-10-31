module GenerateOriginalObjectConcern

    extend ActiveSupport::Concern

    included do
        helper_method :generate_original_series_object,
        :generate_original_novel_object,
        :generate_original_favorites_object,
        :generate_original_comments_object,
        :generate_original_user_object,
        :generate_original_tag_object,
        :generate_original_relationships_object
    end


#Read index / showで取得するオリジナルのオブジェクト

    #Series

        #Seriesオブジェクト1件を生成
        def generate_original_series_object(series_data)
            # Series1件
            @series = series_data[:object]
            data_type = series_data[:data_type]
            crud_type = series_data[:crud_type]
            # Novels全件（Seriesが所有する）
            @novels = @series.novels
            # Favorites数の合計値
            @favorites = generate_original_favorites_object(@novels, data_type)
            # Comments数の合計値
            @comments = generate_original_comments_object(@novels, data_type)
            # Stag NovelTags全件
            @tags = loop_array_and_get_one_tag(
                object: @series.novel_tags,
                data_type: data_type
            )
            case data_type
            when "series", "series_tag", "user"
                case crud_type
                when "show"
                    {
                        series: @series,
                        novels_count: @novels.count,
                        favorites_count: @favorites,
                        comments_count: @comments,
                        tags: @tags,
                        novels: @novels,
                    }
                when "index"
                    {
                        series: @series,
                        novels_count: @novels.count,
                        favorites_count: @favorites,
                        comments_count: @comments,
                        tags: @tags,
                    }
                end
            end
        end



    #Novels

        #Novelsオブジェクト1件を生成
        def generate_original_novel_object(novel_data)
            # Novels1件
            @novel = novel_data[:object]
            data_type = novel_data[:data_type]
            if release?(novel_data)
                # Series1件（Novelに紐付けされた）
                @series = @novel.novel_series
                # Novels全件
                @novels = @series.novels
                #Novels 目次用のID群
                @novels_ids = loop_array_and_get_one_novel(
                    object: @novels,
                    data_type: data_type,
                )
                # Favorites全件（このNovelをお気に入りにしたユーザー）
                @favorites = generate_original_favorites_object(@novel, data_type)
                # Comments全件（このNovelにコメントしたユーザー）
                @comments = generate_original_comments_object(@novel, data_type)
                {
                    series: @series,
                    novel: @novel,
                    novels_ids: @novels_ids,
                    novels_count: @novels.count,
                    favorites_obj: @favorites,
                    comments_obj: @comments,
                }
            elsif !release?(novel_data)
                return_unrelease_data()
            end
        end



    #Favorite

        # Favoritesオブジェクト
        def generate_original_favorites_object(data_for_favorites, data_type)
            case data_type
            when "series", "series_tag", "Users#show"
                # Favorite 各Novelsが持つお気に入り数
                @count = loop_array_and_get_one_data_count(data_for_favorites, "call_favorites_count")
                # Favorite数の合計値
                return @count.flatten.sum {|hash| hash[:favorites_count]}
            when "novel"
                # Favorite全件（Novelsをお気に入りにしたユーザー）
                @favorites = data_for_favorites.novel_favorites
                # Favorite数の合計値
                count = items_counter(data_for_favorites, "call_favorites_count")
                @favorites_count = count.flatten.sum {|hash| hash[:favorites_count]}
                {
                    favorites_count: @favorites_count,
                    favorites: loop_array_and_get_one_favorites(@favorites, data_type)
                }
            end
        end


    #Comment

        # Commentsオブジェクト生成
        def generate_original_comments_object(data_for_comments, data_type)
            case data_type
            when "series", "series_tag", "NovelSeries#show", "Users#show"
                #Comment Novelの持つコメント数
                @count = loop_array_and_get_one_data_count(data_for_comments, "call_comments_count")
                #Comment コメント総の合計値
                return @count.flatten.sum{|hash| hash[:comments_count]}
            when "novel"
                # Commentしたユーザーのデータ
                @comments = data_for_comments.comments
                {
                    comments_count: @comments.count,
                    comments: loop_array_and_get_one_comment(@comments, data_type)
                }
            end
        end


    # Utag(UserTags)
    # Stag(NovelTags)
    def generate_original_tag_object(tag_data)
        tag = tag_data[:object]
        data_type = tag_data[:data_type]
        case data_type
        when "series_tag"
            series_object = loop_array_and_get_one_series(
                object: tag.novel_series,
                data_type: data_type,
                crud_type: "index"
                # Seriesオブジェクトは"index"で取得したい
            ).compact
                    # → loop_array_concern.rb
            tag_object = return_tag_data(tag, data_type)
                    # → return_various_data_concern.rb
            {
                tag: tag_object,
                series: series_object,
            }
        when "user_tag"
            if tag.users.nil?
                return {messages: "ユーザーは存在しません。"}
            else
                # ユーザーオブジェクト1件取得
                users_object = loop_array_and_get_one_user(
                    object: tag.users,
                    data_type: data_type,
                    crud_type: "index"
                    # Seriesオブジェクトは"index"で取得したい
                )
                        # → loop_array_concern.rb
                # タグオブジェクト生成
                tag_object = return_tag_data(tag, data_type)
                        # → return_various_data_concern.rb
                {
                    tag: tag_object,
                    users: users_object,
                }
            end
        end
    end


    #User

        # User1件
        def generate_original_user_object(user_data)
            user = user_data[:object]
            data_type = user_data[:data_type]
            case data_type
            when "user"
                #User ユーザーデータ
                @user = return_user_data(object: user, data_type: data_type)
                #UTag そのユーザーが登録しているタグ全件
                @user_tags = loop_array_and_get_one_tag(object: user.user_tags, data_type: data_type)
                # ユーザーのフォロー/フォロワーデータ
                @relationships = generate_original_relationships_object(object: user, data_type: data_type)
                #Series ユーザーの投稿したSeries全件
                @user_series = loop_array_and_get_one_series(object: user.novel_series, data_type: "series", crud_type: "index").compact
                #Favorites ユーザーがお気に入りにしたSeries
                series_data = loop_array_and_get_one_favorites(user.novel_favorites, data_type)
                @user_favorites_series = loop_array_and_get_one_series(object: series_data, data_type: "series", crud_type: "index").compact.uniq
                    # → お気に入りする小説は複数存在する。そうするとSeriesを取得した際に重複するので「.uniq」で、重複した配列を除く。
                return {
                    user: @user,
                    user_tags: @user_tags,
                    user_relationships: @relationships,
                    user_series_count: @user_series.count,
                    user_series: @user_series,
                    user_favorites_series_count: @user_favorites_series.count,
                    user_favorites_series: @user_favorites_series,
                }
            when "followings"
                followings = loop_array_and_get_one_user(
                    object: user.followings,
                    data_type: data_type,
                )
                {
                    user: user.nickname,
                    users_count: followings.count,
                    users: followings,
                }
            when "followers"
                followers = loop_array_and_get_one_user(
                    object: user.followers,
                    data_type: data_type,
                )
                {
                    user: user.nickname,
                    users_count: followers.count,
                    users: followers,
                }
            end
        end

        # フォロー/フォロワーオブジェクト
        def generate_original_relationships_object(relationships_data)
            followings = relationships_data[:object].followings
            followers = relationships_data[:object].followers
            is_on = followers.include?(current_user)
            data_type = relationships_data[:data_type]
            case data_type
            when "user"
                {
                    followings_count: followings.count,
                    followers_count: followers.count,
                    following_status: is_on,
                }
            end
        end


end