require 'rails_helper'

RSpec.describe "Relationships", type: :request do

  before do
    # ログイン（@user）
    login()
    # フォローする相手のユーザー
    @other_user = FactoryBot.create(:user)
    # フォロー関係の生成
    @relationship = FactoryBot.create(:relationship, user_id: @user.id, follow_id: @other_user.id)
  end

  context "認証済みユーザーの場合" do
    describe "POST /api/v1/relationships" do
      # フォロー生成
      context "異なるユーザーをフォローする場合" do
        before do
          user = FactoryBot.create(:user)
          request_post_relationship(user)
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "正しいJSONレスポンスを返すこと" do
          expect_save_ok(response)
        end
      end
      context "自分自身をフォローしようとした場合" do
        before do
          request_post_relationship(@user)
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "自分自身をフォローできないこと" do
          json = JSON.parse(response.body)
          expect("自分自身をフォローすることは出来ません。").to eq json["errors"]
        end
      end
    end
    # フォロー解除
    describe "DELETE /api/v1/relationships/:id" do
      before do
        # 異なるユーザーのフォローを外す
        delete "/api/v1/relationships/#{@relationship.follow_id}"
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "正しいJSONレスポンスを返すこと" do
        expect_delete_ok(response)
      end
    end
  end

  context "未認証ユーザーの場合" do
    before do
      delete "/logout"
    end
    # フォロー生成
    describe "POST /api/v1/relationships" do
      before do
        request_post_relationship(@user)
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "認証が必要であるというレスポンスを返すこと" do
        expect_need_auth(response)
      end
    end
    # フォロー解除
    describe "DELETE /api/v1/relationships/:id" do
      before do
        delete "/api/v1/relationships/#{@relationship.follow_id}"
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "認証が必要であるというレスポンスを返すこと" do
        expect_need_auth(response)
      end
    end
  end

  # フォローしているユーザー一覧
  describe "GET /api/v1/relationships/:id/followings" do
    before do
      # 4人のフォローユーザーを作成（最上部で定義したのと合わせると5人）
      create_multiple_relationships({user: @user, type: "followings"})
      get "/api/v1/relationships/#{@user.id}/followings"
    end
    it "200を返すこと" do
      expect(response.status).to eq 200
    end
    it "フォローユーザー一覧のページであること" do
      json = JSON.parse(response.body)
      expect("followings").to eq json["data_type"]
    end
    it "ログインユーザーのフォローユーザーページであること" do
      expect_return_current_user(response, @user)
    end
    it "5人のフォローユーザーを返すこと" do
      expect_relationship_users_length(response, 5)
    end
  end

  # フォロワー一覧
  describe "GET /api/v1/relationships/:id/followers" do
    before do
      # 4人のフォロワーを作成
      create_multiple_relationships({user: @user, type: "followers"})
      get "/api/v1/relationships/#{@user.id}/followers"
    end
    it "200を返すこと" do
      expect(response.status).to eq 200
    end
    it "フォロワー一覧のページであること" do
      json = JSON.parse(response.body)
      expect("followers").to eq json["data_type"]
    end
    it "ログインユーザーのフォローワーページであること" do
      expect_return_current_user(response, @user)
    end
    it "4人のフォロワーを返すこと" do
      expect_relationship_users_length(response, 4)
    end
  end

end
