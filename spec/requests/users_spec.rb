require 'rails_helper'

RSpec.describe "Users", type: :request do
  # Users-Show
  describe "GET api/v1/user" do
    before do
      @user = FactoryBot.create(:user)
      get api_v1_user_path(@user)
      @json = JSON.parse(response.body)
      # @json = {
        # "status"=>200,
        # "selection"=>nil,
        # "object"=>{"user"=>{"user_id"=>108, "nickname"=>"User13", "profile"=>""},
        # "user_tags"=>[],
        # "user_relationships"=>{
        #   "followings_count"=>0,
        #   "followers_count"=>0,
        #   "following_status"=>false
        #   },
        # "user_series_count"=>0,
        # "user_series"=>[],
        # "user_favorites_series_count"=>0,
        # "user_favorites_series"=>[]},
        # "data_type"=>"user",
        # "crud_type"=>"show"
        # }

    end

    it "200を返すこと" do
      expect(response).to be_success
      expect(response.status).to eq 200
    end
  end

  describe "POST /api/v1/users" do
    before do
      @user_params = FactoryBot.attributes_for(:user)
      @user_params2 = FactoryBot.attributes_for(:user, nickname: "tester_user2", email: "tester_user2@example.com")
    end

    context "全てのパラメータが揃っている場合" do
      it "200を返す" do
        sign_in @user_params
        post "/api/v1/users", params: {user: @user_params}
        expect(response).to have_http_status(:ok)
      end
      it "成功時のJSONレスポンスを返す" do
        post "/api/v1/users", params: {user: @user_params2}
        expect(JSON.parse(response.body)).to eq({
          "status"=>"created",
          "object"=>{
            "id"=>User.find_by(email: "tester_user2@example.com").id,
            "nickname"=>"tester_user2"
            },
            "successful"=>"正常に保存されました。",
            "data_type"=>"user",
            "crud_type"=>"create"}
          )
      end
      it "ユーザーを登録する" do
        expect { post "/api/v1/users", params: {user: @user_params2}}.to change(User, :count).by(1)
      end
    end

    context "emailパラメータが不足している場合" do
      it "unprocessable_entityを返す"
      it "パラメータ不正のJSONレスポンスを返す"
      it "ユーザーを登録しない"
    end

    context "emailがすでに登録されている場合" do
      it "unprocessable_entityを返す"
      it "email重複エラーのJSONレスポンスを返す"
      it "ユーザーを登録しない"
    end

  end
end
