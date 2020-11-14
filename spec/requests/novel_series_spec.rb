require 'rails_helper'

RSpec.describe "NovelSeries", type: :request do

  context "認証済みユーザーの場合" do
    let :credentials do
      {email: "authorization@example.com", password: "password", password_confirmation: "password"}
    end

    let :user do
      FactoryBot.create(:user, credentials)
    end

    before do
      post "/login", params: {user: credentials}
    end

    describe "GET api/v1/novel_series" do
      it "200を返すこと" do
        get root_path
        expect(response).to be_success
        expect(response.status).to eq 200
      end
    end

  end


end
