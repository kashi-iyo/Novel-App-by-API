require 'rails_helper'

RSpec.describe "Sessions", type: :request do

  context "未ログインの場合" do
    before do
      @credentials = {
        email: "authorization@example.com",
        password: "password",
        password_confirmation: "password"}
      @user = FactoryBot.create(:user, @credentials)
      delete "/logout"
    end

    describe "GET /login" do
      before do
        post "/login", params: {user: @credentials}
      end
      it "200を返すこと" do
        expect(response).to have_http_status(200)
      end
      it "正しいJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("正常にログイン出来ました。").to eq json["successful"]
      end
      it "ログイン状態がtrueであること" do
        expect(is_logged_in?).to be_truthy
      end
    end

    describe "GET /logged_in" do
      before do
        get "/logged_in"
      end
      it "200を返すこと" do
        expect(response).to have_http_status(200)
      end
      it "正しいJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        puts "#{json}"
        expect(false).to eq json["logged_in"]
      end
      it "ログイン状態がfalseであること" do
        expect(is_logged_in?).to be_falsey
      end
    end

    describe "DELETE /logout" do
      before do
        delete "/logout"
      end
      it "200を返すこと" do
        expect(response).to have_http_status(200)
      end
      it "正しいJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("不正なアクセスです。").to eq json["errors"]
      end
      it "ログイン状態がfalseであること" do
        expect(is_logged_in?).to be_falsey
      end
    end
  end

  context "ログインしている場合" do
    before do
      @credentials = {
        email: "authorization@example.com",
        password: "password",
        password_confirmation: "password"}
      @user = FactoryBot.create(:user, @credentials)
      post "/login", params: {user: @credentials}
    end

    describe "GET /login" do
      before do
        post "/login", params: {user: @credentials}
      end
      it "200を返すこと" do
        expect(response).to have_http_status(200)
      end
      it "正しいJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("すでにログインしています。").to eq json["errors"]
      end
      it "ログイン状態がtrueであること" do
        expect(is_logged_in?).to be_truthy
      end
    end

    describe "GET /logged_in" do
      before do
        get "/logged_in", params: {user: @credentials}
      end
      it "200を返すこと" do
        expect(response).to have_http_status(200)
      end
      it "正しいJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect(true).to eq json["logged_in"]
      end
      it "ログイン状態がtrueであること" do
        expect(is_logged_in?).to be_truthy
      end
    end

    describe "DELETE /logout" do
      before do
        delete "/logout"
      end
      it "200を返すこと" do
        expect(response).to have_http_status(200)
      end
      it "正しいJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        puts "#{json}"
        expect(false).to eq json["logged_in"]
      end
      it "ログイン状態がfalseであること" do
        expect(is_logged_in?).to be_falsey
      end
    end
  end

end
