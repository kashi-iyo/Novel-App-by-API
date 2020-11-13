require 'rails_helper'

RSpec.describe "NovelSeries", type: :request do
  describe "GET api/v1/novel_series" do
    context "認証済みのユーザーの場合" do
      before do
        @user = FactoryBot.create(:user)
      end
    end

    it "200を返すこと" do
      get root_path
      expect(response).to be_success
      expect(response.status).to eq 200
    end
  end
end
