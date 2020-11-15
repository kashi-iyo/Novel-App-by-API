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

end