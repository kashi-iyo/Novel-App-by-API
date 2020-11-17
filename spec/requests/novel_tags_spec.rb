require 'rails_helper'

RSpec.describe "NovelTags", type: :request do
  # タグ一覧
  describe "GET /api/v1/novel_tags" do
    before do
      @tags = FactoryBot.create_list(:novel_tag, 5)
      get "/api/v1/novel_tags"
    end
    it "200を返すこと" do
      expect(response.status).to eq 200
    end
    it "正しいJSONレスポンスを返すこと" do
      json = JSON.parse(response.body)
      expect(@tags.length).to eq json["object"]["tags"].length
    end
  end

  # タグ1件で絞り込みしたページ
  describe "GET /api/v1/novel_tags/:id" do
    before do
      # 1件のタグ・5件のシリーズを作成した後、タグとシリーズを関連付け
      # @tag, @seriesを返す
      return_one_tag_and_multiple_series()
      get "/api/v1/novel_tags/#{@tag.id}"
    end
    it "200を返すこと" do
      expect(response.status).to eq 200
    end
    it "正しいJSONレスポンスを返すこと" do
      json = JSON.parse(response.body)
      expect(@tag.id).to eq json["object"]["tag"]["tag_id"]
    end
    it "1件のタグに関連付けされたシリーズのJSONレスポンスを返すこと" do
      json = JSON.parse(response.body)
      expect(@series.length).to eq json["object"]["series"].length
    end
  end

  # 1件のタグで絞り込んだ上で
  describe "GET /api/v1/novel_tags/:id/:selected_params" do
    before do
      # @tag, @seriesを返す
      return_one_tag_and_multiple_series()
      # 新規のシリーズを作成する（小説1件、お気に入り1件、コメント1件、タグ1件を持つ）
      # @new_seriesを返す
      return_series_having_items()
    end
    # 新着順に並び替える
    context "新着順に並び替える場合" do
      before do
        get "/api/v1/novel_tags/#{@tag.id}/new"
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "新たに作成された投稿が最初になること" do
        json = JSON.parse(response.body)["object"]["series"].first
        expect(@new_series.id).to eq json["series"]["id"]
      end
    end
    # 古い順に並び替える
    context "古い順に並び替える場合" do
      before do
        get "/api/v1/novel_tags/#{@tag.id}/old"
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "新しい投稿が最後になること" do
        json = JSON.parse(response.body)["object"]["series"].last
        expect(@new_series.id).to eq json["series"]["id"]
      end
    end
    # お気に入りが多い順に並び替える
    context "お気に入りが多い順に並び替える場合" do
      before do
        get "/api/v1/novel_tags/#{@tag.id}/more_favo"
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "お気に入りが多い投稿が最初になること" do
        json = JSON.parse(response.body)["object"]["series"].first
        expect(@new_series.id).to eq json["series"]["id"]
      end
    end
    # お気に入りが少ない順に並び替える
    context "お気に入りが少ない順に並び替える場合" do
      before do
        get "/api/v1/novel_tags/#{@tag.id}/less_favo"
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "お気に入りが多い投稿が最後になること" do
        json = JSON.parse(response.body)["object"]["series"].last
        expect(@new_series.id).to eq json["series"]["id"]
      end
    end
    # コメントが多い順に並び替える
    context "コメントが多い順に並び替える場合" do
      before do
        get "/api/v1/novel_tags/#{@tag.id}/more_comment"
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "コメントが多い投稿が最初になること" do
        json = JSON.parse(response.body)["object"]["series"].first
        expect(@new_series.id).to eq json["series"]["id"]
      end
    end
    # お気に入りが少ない順に並び替える
    context "お気に入りが少ない順に並び替える場合" do
      before do
        get "/api/v1/novel_tags/#{@tag.id}/less_favo"
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "お気に入りが多い投稿が最後になること" do
        json = JSON.parse(response.body)["object"]["series"].last
        expect(@new_series.id).to eq json["series"]["id"]
      end
    end
  end
end
