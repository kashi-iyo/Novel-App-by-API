require 'rails_helper'

RSpec.describe "Users", type: :request do
  # 認証済みユーザーの場合==============================
  context "認証済みユーザーの場合" do
    before do
      @user = FactoryBot.create(:user)
    end
    # Users-Show
    describe "GET api/v1/user" do
      before do
        get "/api/v1/users"
        @json = JSON.parse(response.body)
      end
      it "正常なレスポンスを返すこと" do
        expect(response).to be_success
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
    end
  end
  # 認証済みユーザーの場合==============================

  # 認証済みユーザーでない場合==============================
  context "認証済みユーザーでない場合" do
    before do
      @user = FactoryBot.create(:user)
    end

    # Users-Show
    describe "GET api/v1/user" do
      before do
        get "/api/v1/users"
        @json = JSON.parse(response.body)
      end
      it "正常なレスポンスを返すこと" do
        expect(response).to be_success
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
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
          expect(JSON.parse(response.body)).to eq(created_object({
              id: User.find_by(email: @email).id,
              nickname: @nickname,
              data_type: "user"
            })
          )
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
            expect_error_response(@params, {errors: ["Email can't be blank", "Email is invalid"]})
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
            expect_error_response(@params, {errors: ["Email is invalid"]})
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
            expect_error_response(@params, {errors: ["Nickname can't be blank"]})
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
            expect_error_response(@params, {errors: ["Account can't be blank"]})
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
            expect_error_response(@params, {errors: ["Password can't be blank"]})
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
            expect_error_response(@params, {errors: ["Email has already been taken"]})
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
            expect_error_response(@params, {errors: ["Nickname has already been taken"]})
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
            expect_error_response(@params, {errors: ["Account has already been taken"]})
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
            expect_error_response(@params, {errors: ["Nickname is too long (maximum is 30 characters)"]})
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
            expect_error_response(@params, {errors: ["Account is too long (maximum is 15 characters)"]})
          end
          it "ユーザーを登録しない" do
            expect_not_change_count(request_post(@params), User)
            expect(is_logged_in?).to be_falsey
          end
        end
      end

    end
    # 認証済みユーザーでない場合==============================

  end


end
