require 'rails_helper'

RSpec.describe "UserTags", type: :request do
  describe "GET /api/v1/user_tags" do
    before do
      @tags = FactoryBot.create_list(:user_tag, 5)
      get "/api/v1/user_tags"
    end
    it "200を返すこと" do
      expect(response.status).to eq 200
    end
    it "正しいJSONレスポンスを返すこと" do
      json = JSON.parse(response.body)
      expect(@tags.length).to eq json["object"]["tags"].length
    end
  end

  describe "GET /api/v1/user_tags/:id" do
    before do
      @tag = FactoryBot.create(:user_tag)
      get "/api/v1/user_tags/#{@tag.id}"
    end
    it "200を返すこと" do
      expect(response.status).to eq 200
    end
    it "正しいJSONレスポンスを返すこと" do
      json = JSON.parse(response.body)
      expect(@tag.id).to eq json["object"]["tag"]["tag_id"]
    end
  end
end
