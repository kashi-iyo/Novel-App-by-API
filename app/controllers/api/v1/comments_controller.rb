class Api::V1::CommentsController < ApplicationController

    before_action :logged_in_user, only: [:create, :destroy]
    before_action :set_novel, only: [:create]
    before_action :set_comment, only: [:destroy]


    def create
        @comment = current_user.comments.new(comment_params)
        helpers.pass_object_to_crud(
            @comment,   #object
            {},         #params
            @novel,     #association_data
            "comment",  #data_type
            "create"    #crud_type
        )
    end

    def destroy
        helpers.pass_object_to_crud(
            @comment,   #object
            {},         #params
            {},         #association_data
            "comment",  #data_type
            "destroy"   #crud_type
        )
    end

    private

    def comment_params
        params.require(:comment).permit(:content, :novel_id, :commenter)
    end

    def set_novel
        if Novel.find_by(id: params[:novel_id]).nil?
            return_not_present_data()
        else
            @novel = Novel.find_by(id: params[:novel_id])
        end
    end

    def set_comment
        if Comment.find_by(id: params[:id], novel_id: params[:novel_id]).nil?
            return_not_present_data()
        else
            @comment = Comment.find_by(id: params[:id], novel_id: params[:novel_id])
        end
    end

end