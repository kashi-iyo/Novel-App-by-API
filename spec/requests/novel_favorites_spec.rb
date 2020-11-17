require 'rails_helper'

RSpec.describe "NovelFavorites", type: :request do
  context "認証済みユーザーの場合" do
    before do
      # お気に入りを行うユーザーでログイン（@user）
      login()
      @other_user = FactoryBot.create(:user, nickname: "作者")
      # お気に入りを残すための小説を作（@series, @novel）
      create_novel_data(@other_user)
      # お気に入りパラメータ
      @favorite_params = FactoryBot.attributes_for(
        :novel_favorite, user_id: @user.id, novel_id: @novel.id, favoriter: @user.nickname)
    end

    # お気に入り作成
    describe "POST /api/v1/novels/:novel_id/novel_favorites" do
      before do
        post "/api/v1/novels/#{@novel.id}/novel_favorites", params: {novel_favorite: @favorite_params}
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "正常なJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("正常に保存されました。").to eq json["successful"]
      end
    end

    # お気に入り削除
    describe "DELETE /api/v1/novels/:novel_id/novel_favorites/:id" do
      before do
        FactoryBot.create(
          :novel_favorite, novel_id: @novel.id, user_id: @user.id)
        delete "/api/v1/novels/#{@novel.id}/novel_favorites/#{@user.id}"
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

  context "未認証のユーザーの場合" do
    before do
      @user = FactoryBot.create(:user)
      # お気に入りを残すための小説を作成
      create_novel_data(@user)
      delete "/logout"
    end

    # お気に入り作成
    describe "POST /api/v1/novels/:novel_id/novel_favorites" do
      before do
        post "/api/v1/novels/#{@novel.id}/novel_favorites", params: {novel_favorite: @favorite_params}
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "正常なJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("この機能を使用するにはログインまたは、新規登録が必要です。").to eq json["errors"]
      end
    end

    # お気に入り削除
    describe "DELETE /api/v1/novels/:novel_id/novel_favorites/:id" do
      before do
        FactoryBot.create(:novel_favorite, novel: @novel, user: @user)
        delete "/api/v1/novels/#{@novel.id}/novel_favorites/#{@user.id}"
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "正常なJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("この機能を使用するにはログインまたは、新規登録が必要です。").to eq json["errors"]
      end
    end
  end
end
