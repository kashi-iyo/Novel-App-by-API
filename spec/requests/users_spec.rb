require 'rails_helper'

RSpec.describe "Users", type: :request do

  context "認証が不必要な場合" do
    # Users-Show
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

    # Users-Create
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
        it "成功時のJSONレスポンスを返すこと" do
          request_post(@params)
          json = JSON.parse(response.body)
          expect(@nickname).to eq json["object"]["nickname"]
        end
        it "ユーザーを登録&ログインすること" do
          expect_change_count(request_post(@params), User)
          expect(is_logged_in?).to be_truthy
        end
      end

      #パラメータに不足がある場合=====================
      context "パラメータに不足がある場合" do
        context "emailパラメータが不足している場合" do
          before do
            @params = return_user_params({permit: { email: nil }})
          end
          it "200を返す" do
            expect_http_status(@params, 200)
          end
          it "パラメータ不正のJSONレスポンスを返す" do
            request_post(@params)
            json = JSON.parse(response.body)
            expect(["Email can't be blank", "Email is invalid"]).to eq json["errors"]
          end
          it "ユーザーを登録しない" do
            expect_not_change_count(request_post(@params), User)
            expect(is_logged_in?).to be_falsey
          end
        end

        context "emailパラメータが不正な場合" do
          before do
            @params = return_user_params({permit: { email: "aaaaaaaaa" }})
          end
          it "200を返す" do
            expect_http_status(@params, 200)
          end
          it "パラメータ不正のJSONレスポンスを返す" do
            request_post(@params)
            json = JSON.parse(response.body)
            expect(["Email is invalid"]).to eq json["errors"]
          end
          it "ユーザーを登録しない" do
            expect_not_change_count(request_post(@params), User)
            expect(is_logged_in?).to be_falsey
          end
        end

        context "nicknameパラメータが不足している場合" do
          before do
            @params = return_user_params({permit: { nickname: nil }})
          end
          it "200を返す" do
            expect_http_status(@params, 200)
          end
          it "パラメータ不足エラーのJSONレスポンスを返す" do
            request_post(@params)
            json = JSON.parse(response.body)
            expect(["Nickname can't be blank"]).to eq json["errors"]
          end
          it "ユーザーを登録しない" do
            expect_not_change_count(request_post(@params), User)
            expect(is_logged_in?).to be_falsey
          end
        end

        context "account_idパラメータが不足している場合" do
          before do
            @params = return_user_params({permit: { account_id: nil }})
          end
          it "200を返す" do
            expect_http_status(@params, 200)
          end
          it "account_id不足エラーのJSONレスポンスを返す" do
            request_post(@params)
            json = JSON.parse(response.body)
            expect(["Account can't be blank"]).to eq json["errors"]
          end
          it "ユーザーを登録しない" do
            expect_not_change_count(request_post(@params), User)
            expect(is_logged_in?).to be_falsey
          end
        end

        context "passwordが不足している場合" do
          before do
            @params = return_user_params({permit: { password: nil }})
          end
          it "200を返す" do
            expect_http_status(@params, 200)
          end
          it "password不足エラーのJSONレスポンスを返す" do
            request_post(@params)
            json = JSON.parse(response.body)
            expect(["Password can't be blank"]).to eq json["errors"]
          end
          it "ユーザーを登録しない" do
            expect_not_change_count(request_post(@params), User)
            expect(is_logged_in?).to be_falsey
          end
        end
      end

      #パラメータに重複がある場合=====================
      context "パラメータに重複がある場合" do
        context "emailがすでに登録されている場合" do
          before do
            @params = return_duplicate_params({email: "tester_user@example.com"})
          end
          it "200を返す" do
            expect_http_status(@params, 200)
          end
          it "email重複エラーのJSONレスポンスを返す" do
            request_post(@params)
            json = JSON.parse(response.body)
            expect(["Email has already been taken"]).to eq json["errors"]
          end
          it "ユーザーを登録しない" do
            expect_not_change_count(request_post(@params), User)
            expect(is_logged_in?).to be_falsey
          end
        end

        context "nicknameがすでに登録されている場合" do
          before do
            @params = return_duplicate_params({nickname: "duplicate_user"})
          end
          it "200を返す" do
            expect_http_status(@params, 200)
          end
          it "nickname重複エラーのJSONレスポンスを返す" do
            request_post(@params)
            json = JSON.parse(response.body)
            expect(["Nickname has already been taken"]).to eq json["errors"]
          end
          it "ユーザーを登録しない" do
            expect_not_change_count(request_post(@params), User)
            expect(is_logged_in?).to be_falsey
          end
        end

        context "account_idがすでに登録されている場合" do
          before do
            @params = return_duplicate_params({account_id: "duplicate_ac"})
          end
          it "200を返す" do
            expect_http_status(@params, 200)
          end
          it "account_id重複エラーのJSONレスポンスを返す" do
            request_post(@params)
            json = JSON.parse(response.body)
            expect(["Account has already been taken"]).to eq json["errors"]
          end
          it "ユーザーを登録しない" do
            expect_not_change_count(request_post(@params), User)
            expect(is_logged_in?).to be_falsey
          end
        end
      end

      #パラメータの文字数制限に引っかかる場合
      context "パラメータが文字数制限に引っかかる場合" do
        context "nickname文字数が30文字以上の場合" do
          before do
            @params = return_user_params({permit: { nickname: "nickname" * 31 }})
          end
          it "200を返す" do
            expect_http_status(@params, 200)
          end
          it "パラメータ不正のJSONレスポンスを返す" do
            request_post(@params)
            json = JSON.parse(response.body)
            expect(["Nickname is too long (maximum is 30 characters)"]).to eq json["errors"]
          end
          it "ユーザーを登録しない" do
            expect_not_change_count(request_post(@params), User)
            expect(is_logged_in?).to be_falsey
          end
        end

        context "account_id文字数が15文字以上の場合" do
          before do
            @params = return_user_params({permit: { account_id: "account_id" * 16 }})
          end
          it "200を返す" do
            expect_http_status(@params, 200)
          end
          it "パラメータ不正のJSONレスポンスを返す" do
            request_post(@params)
            json = JSON.parse(response.body)
            expect(["Account is too long (maximum is 15 characters)"]).to eq json["errors"]
          end
          it "ユーザーを登録しない" do
            expect_not_change_count(request_post(@params), User)
            expect(is_logged_in?).to be_falsey
          end
        end
      end
    end

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

  context "認証が必要な場合" do
    # ログインする
    before do
      @credentials = {
          email: "authorization@example.com",
          password: "password",
          password_confirmation: "password"}
        @before_user = FactoryBot.create(:user, @credentials)
        post "/login", params: {user: @credentials}
    end

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
