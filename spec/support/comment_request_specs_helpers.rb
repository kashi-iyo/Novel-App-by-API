module CommentRequestSpecsHelpers

    def request_post_comment(novel, comment_params)
        post "/api/v1/novels/#{novel.id}/comments", params: {comment: comment_params}
    end

    def request_delete_comment(novel, comment)
        delete "/api/v1/novels/#{novel.id}/comments/#{comment.id}"
    end

end