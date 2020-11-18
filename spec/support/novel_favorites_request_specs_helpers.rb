module NovelFavoritesRequestSpecsHelpers

    def request_post_favorites(novel, favorite_params)
        post "/api/v1/novels/#{novel.id}/novel_favorites", params: {novel_favorite: favorite_params}
    end

    def request_delete_favorites(novel, user)
        delete "/api/v1/novels/#{novel.id}/novel_favorites/#{user.id}"
    end

end