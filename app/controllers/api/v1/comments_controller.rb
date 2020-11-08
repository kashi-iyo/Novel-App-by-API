class Api::V1::CommentsController < ApplicationController

    before_action :logged_in_user, only: [:create, :destroy]
    before_action :set_novel, only: [:create]
    before_action :set_comment, only: [:destroy]


    def create
        crud_object(
            object: current_user.comments,
            params: comment_params,
            association_data: @novel,
            data_type: "comment",
            crud_type: "create"
        )
    end

    def destroy
        pass_object_to_crud(
            object: @comment,
            data_type: "comment",
            crud_type: "destroy"
        )
    end

    private

    def comment_params
        params.require(:comment).permit(:content, :novel_id, :commenter)
    end

    def set_novel
        @novel = check_existing?(
            object: Novel,
            params: params[:novel_id],
            data_type: "novel")
            # → validates_features_concern.rb
    end

    def set_comment
        @comment = check_existing?(
            object: Comment,
            params: params[:id],
            params2: params[:novel_id],
            data_type: "comment")
            # → validates_features_concern.rb
    end

end