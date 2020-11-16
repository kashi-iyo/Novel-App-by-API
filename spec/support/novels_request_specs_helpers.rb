module NovelsRequestSpecsHelpers

    def create_novel_data(user)
        @series = FactoryBot.create(:novel_series, :is_release, owner: user)
        @novel = FactoryBot.create(:novel, :is_release, novel_series: @series)
    end

    def create_unrelease_novel_data(user)
        @series = FactoryBot.create(:novel_series, :is_release, owner: user)
        @novel = FactoryBot.create(:novel, novel_series: @series)
    end

    def create_novel_attributes(user)
        @series = FactoryBot.create(:novel_series, :is_release, owner: user)
        @params = FactoryBot.attributes_for(:novel, novel_series: @series)
    end

    def get_show_novel(user)
        create_novel_data(user)
        get "/api/v1/novel_series/#{@novel.novel_series_id}/novels/#{@novel.id}"
    end

    def get_not_show_unrelease_novel(user)
        create_unrelease_novel_data(user)
        get "/api/v1/novel_series/#{@novel.novel_series_id}/novels/#{@novel.id}"
    end

    def get_edit_novel(user)
        create_novel_data(user)
        get "/api/v1/novel_series/#{@novel.novel_series_id}/novels/#{@novel.id}/edit"
    end

    def request_novel_post(series_id, novel_params)
        post "/api/v1/novel_series/#{series_id}/novels", params: {novel: novel_params}
    end

    def request_novel_update(series_id, novel_id, novel_params)
        put "/api/v1/novel_series/#{series_id}/novels/#{novel_id}", params: {novel: novel_params}
    end

    def request_novel_delete(series_id, novel_id)
        delete "/api/v1/novel_series/#{series_id}/novels/#{novel_id}"
    end

end