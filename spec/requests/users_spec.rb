require 'rails_helper'

RSpec.describe "Users", type: :request do

  context "ログインしていない場合" do
    # ユーザーぺーじ
    describe "GET api/v1/user/:id" do
      before do
        @user = FactoryBot.create(:user, nickname: "users_show")
      end
      before do
        get "/api/v1/users/#{@user.id}"
      end
      it "正常なレスポンスを返すこと" do
        expect(response).to be_success
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "nicknameの一致" do
        json = JSON.parse(response.body)
        expect(@user.nickname).to eq json["object"]["user"]["nickname"]
      end
    end

    # ユーザーの作成
    describe "POST /api/v1/users" do
      context "全てのパラメータが揃っている場合" do
        before do
          @nickname = "tester_user"
          @email = "tester_user@example.com"
          @params = return_user_params(permit: { nickname: @nickname, email: @email })
        end
        it "200を返すこと" do
          expect_http_status(@params, 200)
        end
        it "不正なJSONレスポンスを返すこと" do
          request_post(@params)
          json = JSON.parse(response.body)
          expect("この機能を使用するにはログインまたは、新規登録が必要です。").to eq json["errors"]
        end
        it "ユーザーを登録&ログインすること" do
          expect { request_post(@params) }.to change(User, :count).by(0)
          expect(is_logged_in?).to be_falsey
        end
      end
    end

    # ユーザーの更新
    describe "PUT /api/v1/users/:id" do
      before do
        @before_user = FactoryBot.create(:user)
        @updated_user = FactoryBot.attributes_for(:updated_user)
        put "/api/v1/users/#{@before_user.id}",
        params: {user: {
          nickname: @updated_user["nickname"],
          profile: @updated_user["profile"]}}
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "認証が必要であるというレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("この機能を使用するにはログインまたは、新規登録が必要です。").to eq json["errors"]
      end
    end
  end

  context "ログインしている場合" do
    # ログインする
    before do
      @credentials = {
          email: "authorization@example.com",
          password: "password",
          password_confirmation: "password"}
        @before_user = FactoryBot.create(:user, @credentials)
        post "/login", params: {user: @credentials}
    end

    # ユーザーの更新
    describe "PUT /api/v1/users/:id" do
      before do
        @updated_user = FactoryBot.attributes_for(:updated_user)
        put "/api/v1/users/#{@before_user.id}", params: {user: @updated_user}
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "正常なレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("正常に編集が完了しました。").to eq json["successful"]
      end
    end

    # ユーザーの削除
    describe "DELETE /api/v1/users/:id" do
      before do
        @delete_user = FactoryBot.attributes_for(:delete_user)
        delete "/api/v1/users/#{@before_user.id}", params: {user: @delete_user}
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "正常なレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("正常に削除されました。").to eq json["successful"]
      end
    end
  end

end
