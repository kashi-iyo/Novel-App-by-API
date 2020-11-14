require 'rails_helper'

RSpec.describe "Sessions", type: :request do

  before do
    @credentials = {
      email: "authorization@example.com",
      password: "password",
      password_confirmation: "password"}
    @user = FactoryBot.create(:user, @credentials)
    post "/login", params: {user: @credentials}
  end

  describe "GET /login" do
    it "200を返す" do
      expect(response).to have_http_status(200)
    end
    it "正しいJSONレスポンスを返す" do
      json = JSON.parse(response.body)
      expect("正常にログイン出来ました。").to eq json["successful"]
    end
    it "ログイン状態がtrueであること" do
      expect(is_logged_in?).to be_truthy
    end
  end

  describe "GET /logged_in" do
    before do
      get "/logged_in", params: {user: @credentials}
    end
    it "200を返す" do
      expect(response).to have_http_status(200)
    end
    it "正しいJSONレスポンスを返す" do
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
    it "200を返す" do
      expect(response).to have_http_status(200)
    end
    it "正しいJSONレスポンスを返す" do
      json = JSON.parse(response.body)
      expect(false).to eq json["logged_in"]
    end
    it "ログイン状態がtrueであること" do
      expect(is_logged_in?).to be_falsey
    end
  end
end
