class Api::V1::CommentsController < ApplicationController

    before_action :logged_in_user, only: [:create, :edit, :update, :destroy]
    before_action :set_novel, only: [:index, :edit]
    before_action :set_comment, only: [:edit, :update, :destroy]

    def index
        @comments = @novel.comments
        render json: {
            status: 200,
            comment: @comments,
            keyword: "index_comments"
        }
    end

    def create
        @comment = current_user.comments.new(comment_params)
        if authorized?(@comment)
            if @comment.save
                render json: {
                    status: :created,
                    successful: ["正常に作成されました。"],
                    keyword: "create_comment"
                }
            else
                render json: {
                    errors: ["入力内容に誤りがあります。"],
                    status: :unprocessable_entity
                }
            end
        else
            handle_unauthorized(@comment)
        end
    end

    def edit
        if authorized?(@comment)
            render json: {status: 200, comment: @comment, keyword: "edit_comment"}
        else
            handle_unauthorized(@comment)
        end
    end

    def update
        if authorized?(@comment)
            if @comment.update(comment_params)
                render json: {
                    status: :ok,
                    successful: ["編集が完了しました。"],
                    keyword: "update_comment"
                }
            else
                render json: {
                    errors: ["入力内容に誤りがあります。"],
                    status: :unprocessable_entity
                }
            end
        else
            handle_unauthorized(@comment)
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
        @comment = Comment.find_by(id: params[:id])
    end

end