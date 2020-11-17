require 'rails_helper'

RSpec.describe "Comments", type: :request do

  context "認証済みユーザーの場合" do
    before do
      # コメントを行うユーザーでログイン（@user）
      login()
      @other_user = FactoryBot.create(:user, nickname: "作者")
      # コメントを残すための小説を作成
      create_novel_data(@other_user)
      # コメントパラメータ
      @comment_params = FactoryBot.attributes_for(:comment, user: @user, novel: @novel)
    end

    # コメント作成
    describe "POST /api/v1/novels/:novel_id/comments" do
      before do
        post "/api/v1/novels/#{@novel.id}/comments", params: {comment: @comment_params}
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "正常なJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("正常に保存されました。").to eq json["successful"]
      end
    end

    # コメント削除
    describe "DELETE /api/v1/novels/:novel_id/comments/:id" do
      before do
        comment = FactoryBot.create(:comment, novel: @novel, user: @user)
        delete "/api/v1/novels/#{@novel.id}/comments/#{comment.id}"
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "正常なJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("正常に削除されました。").to eq json["successful"]
      end
    end
  end

  context "未認証ユーザーの場合" do
    before do
      @user = FactoryBot.create(:user)
      # コメントを残すための小説を作成
      create_novel_data(@user)
      delete "/logout"
    end

    # コメント作成
    describe "POST /api/v1/novels/:novel_id/comments" do
      before do
        # コメントパラメータ
        @comment_params = FactoryBot.attributes_for(:comment, user: @user, novel: @novel)
        post "/api/v1/novels/#{@novel.id}/comments", params: {comment: @comment_params}
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "不正なJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("この機能を使用するにはログインまたは、新規登録が必要です。").to eq json["errors"]
      end
    end

    # コメント削除
    describe "DELETE /api/v1/novels/:novel_id/comments/:id" do
      before do
        comment = FactoryBot.create(:comment, novel: @novel, user: @user)
        delete "/api/v1/novels/#{@novel.id}/comments/#{comment.id}"
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "不正なJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("この機能を使用するにはログインまたは、新規登録が必要です。").to eq json["errors"]
      end
    end
  end

end
