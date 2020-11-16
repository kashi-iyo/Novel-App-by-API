module NovelSeriesSpecsHelpers

    def request_post(series_params)
        post "/api/v1/novel_series", params: {novel_series: series_params}
    end

    def request_update(series_params)
        put "/api/v1/novel_series/#{series_params[:id]}", params: {novel_series: series_params[:params]}
    end

    def request_delete(series_params)
        delete "/api/v1/novel_series/#{series_params[:id]}"
    end

    # シリーズにお気に入りやコメントなどのデータを追加する
    def return_series_having_favorites(pass_data)
        # データが追加される小説に紐付けさせるためのシリーズを作成
        @series_having_items = FactoryBot.create_list(
            :novel_series, pass_data[:count], :is_release)
        # データが追加される小説を作成
        novel = @series_having_items.map do |series|
            FactoryBot.create(:novel, novel_series: series)
        end
        # データの追加を行うユーザーを作成
        user = FactoryBot.create(:user)
        # データの追加を実行
        novel.map do |val|
            case pass_data[:type]
            when "favorites"
                FactoryBot.create(:novel_favorite, user: user, novel: val)
            when "comments"
                FactoryBot.create(:comment, user: user, novel: val)
            end
        end
    end

end