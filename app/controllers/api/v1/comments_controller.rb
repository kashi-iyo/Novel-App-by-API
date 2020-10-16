class Api::V1::CommentsController < ApplicationController

    before_action :logged_in_user, only: [:create, :destroy]
    before_action :set_novel, only: [:create]
    before_action :set_comment, only: [:destroy]


    def create
        @comment = current_user.comments.new(comment_params)
        if @comment.save
            # コメント用のデータフォーマット作成(@comments_data)
            data_of_comments_in_novel(@novel)
            render json: {
                status: :created,
                comment: @comments_data[0],
                successful: ["正常に送信されました。"],
                keyword: "create_comment"
            }
        else
            render json: {
                errors: ["入力内容に誤りがあります。"],
                status: :unprocessable_entity
            }
        end
    end

    def destroy
        if authorized?(@comment)
            @comment.destroy
            render json: { head: :no_content, success: "正常に削除されました。" }
        else
            handle_unauthorized(@comment)
        end
    end

    private

    def comment_params
        params.require(:comment).permit(:content, :novel_id, :commenter)
    end

    def set_novel
        @novel = Novel.find_by(id: params[:novel_id])
    end

    def set_comment
        @comment = Comment.find_by(id: params[:id], novel_id: params[:novel_id])
    end

end