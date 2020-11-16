require 'rails_helper'

RSpec.describe "NovelSeries", type: :request do

  # シリーズ全件（認証有無関係ない）
  describe "GET api/v1/novel_series" do
    context "シリーズが公開されている場合" do
      before do
        @series = FactoryBot.create_list(:novel_series, 5, :is_release)
        get root_path
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "5つのシリーズを返すこと" do
        json = JSON.parse(response.body)
        expect(json["object"]["series_count"]).to eq 5
      end
      it "シリーズの配列数が5つであること" do
        json = JSON.parse(response.body)
        expect(json["object"]["series"].length).to eq 5
      end
    end
    context "シリーズが非公開の場合" do
      before do
        @series = FactoryBot.create_list(:novel_series, 5)
        get root_path
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "返すシリーズが0であること" do
        json = JSON.parse(response.body)
        expect(json["object"]["series_count"]).to eq 0
      end
      it "シリーズの配列数が0であること" do
        json = JSON.parse(response.body)
        expect(json["object"]["series"].length).to eq 0
      end
    end
  end

  # selectで並び替えされたシリーズ全件（認証有無関係ない）
  describe "GET /api/v1/selected_series/:selected_params" do
    context "シリーズが公開されている場合" do
      context "新着順になっている場合" do
        before do
          @series = FactoryBot.create_list(:novel_series, 5, :is_release)
          # 新着のデータを作成
          @new_series = FactoryBot.create(:novel_series, :is_release)
          get "/api/v1/selected_series/new"
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "6つのシリーズを返すこと" do
          json = JSON.parse(response.body)
          expect(json["object"]["series_count"]).to eq 6
        end
        it "最初に最新のシリーズが来ること" do
          json = JSON.parse(response.body)["object"]["series"].first
          expect(@new_series.id).to eq json["series"]["id"]
        end
      end
      context "古い順になっている場合" do
        before do
          # 古いシリーズ作成
          @old_series = FactoryBot.create(:novel_series, :is_release)
          @series = FactoryBot.create_list(:novel_series, 5, :is_release)
          get "/api/v1/selected_series/old"
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "6つのシリーズを返すこと" do
          json = JSON.parse(response.body)
          expect(json["object"]["series_count"]).to eq 6
        end
        it "最初に古いシリーズが来ること" do
          json = JSON.parse(response.body)["object"]["series"].first
          expect(@old_series.id).to eq json["series"]["id"]
        end
      end
      context "お気に入りが多い順になっている場合" do
        before do
          @series = FactoryBot.create_list(:novel_series, 5, :is_release)
          # お気に入り付きのシリーズを作成
          return_series_having_favorites({count: 1, type: "favorites"})
          get "/api/v1/selected_series/more_favo"
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "6つのシリーズを返すこと" do
          json = JSON.parse(response.body)
          expect(json["object"]["series_count"]).to eq 6
        end
        it "最初にお気に入りが多いシリーズが来ること" do
          json = JSON.parse(response.body)["object"]["series"].first
          expect(@series_having_items[0].id).to eq json["series"]["id"]
        end
      end
      context "お気に入りが少ない順になっている場合" do
        before do
          @series = FactoryBot.create(:novel_series, :is_release)
          # お気に入り付きのシリーズを作成
          return_series_having_favorites({count: 5, type: "favorites"})
          get "/api/v1/selected_series/less_favo"
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "6つのシリーズを返すこと" do
          json = JSON.parse(response.body)
          expect(json["object"]["series_count"]).to eq 6
        end
        it "最初にお気に入りが多いシリーズが来ること" do
          json = JSON.parse(response.body)["object"]["series"].first
          expect(@series.id).to eq json["series"]["id"]
        end
      end
      context "コメントが多い順になっている場合" do
        before do
          @series = FactoryBot.create_list(:novel_series, 5, :is_release)
          # コメント付きのシリーズを作成
          return_series_having_favorites({count: 1, type: "comments"})
          get "/api/v1/selected_series/more_comment"
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "6つのシリーズを返すこと" do
          json = JSON.parse(response.body)
          expect(json["object"]["series_count"]).to eq 6
        end
        it "最初にコメントが多いシリーズが来ること" do
          json = JSON.parse(response.body)["object"]["series"].first
          expect(@series_having_items[0].id).to eq json["series"]["id"]
        end
      end
      context "コメントが少ない順になっている場合" do
        before do
          @series = FactoryBot.create(:novel_series, :is_release)
          # コメント付きのシリーズを作成
          return_series_having_favorites({count: 5, type: "comments"})
          get "/api/v1/selected_series/less_comment"
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "6つのシリーズを返すこと" do
          json = JSON.parse(response.body)
          expect(json["object"]["series_count"]).to eq 6
        end
        it "最初にコメントが少ないシリーズが来ること" do
          json = JSON.parse(response.body)["object"]["series"].first
          expect(@series.id).to eq json["series"]["id"]
        end
      end
    end
    context "シリーズが非公開の場合" do
      before do
        @series = FactoryBot.create_list(:novel_series, 5)
        get root_path
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "返すシリーズが0であること" do
        json = JSON.parse(response.body)
        expect(json["object"]["series_count"]).to eq 0
      end
      it "シリーズの配列数が0であること" do
        json = JSON.parse(response.body)
        expect(json["object"]["series"].length).to eq 0
      end
    end
  end

  # 認証済みユーザーの場合
  context "認証済みユーザーの場合" do
    before do
      login()
    end

    # シリーズ詳細ページ
    describe "GET api/v1/novel_series/:id" do
      context "シリーズが公開されている場合" do
        before do
          @series = FactoryBot.create(:novel_series, :is_release, series_title: "公開シリーズ")
          get "/api/v1/novel_series/#{@series.id}"
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "正しいJSONレスポンスを返すこと" do
          json = JSON.parse(response.body)
          expect("公開シリーズ").to eq json["object"]["series"]["series_title"]
        end
      end
      context "シリーズが非公開の場合" do
        before do
          # ログインユーザーのシリーズ
          @series = FactoryBot.create(:novel_series, owner: @user)
          # 異なるユーザーのシリーズ
          @other_user_series = FactoryBot.create(:novel_series)
        end

        context "ログインユーザー自身の非公開作品の場合" do
          before do
            # 自身のシリーズへのアクセス
            get "/api/v1/novel_series/#{@series.id}"
          end
          it "200を返すこと" do
            expect(response.status).to eq 200
          end
          it "正しいJSONレスポンスを返すこと" do
            json = JSON.parse(response.body)
            expect("ログインユーザー").to eq json["object"]["series"]["author"]
          end
        end

        context "異なるユーザーの非公開作品の場合" do
          before do
            # 異なるユーザーの非公開シリーズへのアクセス
            get "/api/v1/novel_series/#{@other_user_series.id}"
          end
          it "200を返すこと" do
            expect(response.status).to eq 200
          end
          it "不正なJSONレスポンスを返すこと" do
            json = JSON.parse(response.body)
            expect("アクセス権限がありません。").to eq json["errors"]
          end
        end

      end
    end

    # シリーズ作成
    describe "POST api/v1/novel_series/" do
      before do
        @params = FactoryBot.attributes_for(:novel_series, owner: @user, novel_tag_name: "")
        request_post(@params)
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "正しいJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("正常に保存されました。").to eq json["successful"]
      end
      it "シリーズがDBに追加されていること" do
        expect{request_post(@params)}.to change(NovelSeries, :count).by(1)
      end
    end

    # シリーズ編集
    describe "GET api/v1/novel_series/:id/edit" do
      context "ログインユーザー自身の作品の場合" do
        context "公開されている場合" do
          before do
            @series = FactoryBot.create(
              :novel_series,
              :is_release,
              owner: @user,
              series_title: "公開シリーズ"
            )
            get "/api/v1/novel_series/#{@series.id}/edit"
          end
          it "200を返すこと" do
            expect(response.status).to eq 200
          end
          it "正しいJSONレスポンスを返すこと" do
            json = JSON.parse(response.body)
            expect("公開シリーズ").to eq json["object"]["series_title"]
          end
        end
        context "非公開の場合" do
          before do
            @series = FactoryBot.create(
              :novel_series,
              owner: @user,
              series_title: "非公開シリーズ"
            )
            get "/api/v1/novel_series/#{@series.id}/edit"
          end
          it "200を返すこと" do
            expect(response.status).to eq 200
          end
          it "正しいJSONレスポンスを返すこと" do
            json = JSON.parse(response.body)
            expect("非公開シリーズ").to eq json["object"]["series_title"]
          end
        end
      end

      context "異なるユーザーの作品の場合" do
        before do
          @other_user = FactoryBot.create(:user)
          @series = FactoryBot.create(
            :novel_series,
            :is_release,
            owner: @other_user,
          )
          get "/api/v1/novel_series/#{@series.id}/edit"
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "不正なJSONレスポンスを返すこと" do
          json = JSON.parse(response.body)
          expect("アクセス権限がありません。").to eq json["errors"]
        end
      end
    end

    # シリーズ更新
    describe "PUT api/v1/novel_series/:id" do
      before do
        @updated_params = FactoryBot.attributes_for(:updated_series, owner: @user, novel_tag_name: "")
      end
      context "ログインユーザー自身の作品の場合" do
        before do
          @before_series = FactoryBot.create(
            :novel_series,
            owner: @user,
          )
          request_update({id: @before_series.id, params: @updated_params})
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "正しいJSONレスポンスを返すこと" do
          json = JSON.parse(response.body)
          expect("正常に編集が完了しました。").to eq json["successful"]
        end
      end

      context "異なるユーザーの作品の場合" do
        before do
          @other_user = FactoryBot.create(:user)
          @other_users_series = FactoryBot.create(:updated_series, owner: @other_user)
          request_update({id: @other_users_series.id, params: @updated_params})
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "不正なJSONレスポンスを返すこと" do
          json = JSON.parse(response.body)
          expect("アクセス権限がありません。").to eq json["errors"]
        end
      end
    end

    # シリーズ削除
    describe "DELETE api/v1/novel_series/:id" do
      context "ログインユーザー自身の作品の場合" do
        before do
          @delete_series = FactoryBot.create(:delete_series, owner: @user)
          request_delete(@delete_series)
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "正しいJSONレスポンスを返すこと" do
          json = JSON.parse(response.body)
          expect("正常に削除されました。").to eq json["successful"]
        end
      end

      context "異なるユーザーの作品の場合" do
        before do
          @other_user = FactoryBot.create(:user)
          @other_users_series = FactoryBot.create(:delete_series, owner: @other_user)
          request_delete(@other_users_series)
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "不正なJSONレスポンスを返すこと" do
          json = JSON.parse(response.body)
          expect("アクセス権限がありません。").to eq json["errors"]
        end
      end
    end
  end

  context "未認証のユーザーの場合" do
    before do
      @user = FactoryBot.create(:user)
      delete "/logout"
    end

    # シリーズ詳細
    describe "GET api/v1/novel_series/:id" do
      context "シリーズが公開されている場合" do
        before do
          @series = FactoryBot.create(:novel_series, :is_release, series_title: "公開シリーズ")
          get "/api/v1/novel_series/#{@series.id}"
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "正しいJSONレスポンスを返すこと" do
          json = JSON.parse(response.body)
          expect("公開シリーズ").to eq json["object"]["series"]["series_title"]
        end
      end
      context "シリーズが非公開の場合" do
        before do
          @series = FactoryBot.create(:novel_series)
          get "/api/v1/novel_series/#{@series.id}"
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "不正なJSONレスポンスを返すこと" do
          json = JSON.parse(response.body)
          expect("アクセス権限がありません。").to eq json["errors"]
        end
      end
    end

    # シリーズ作成
    describe "POST api/v1/novel_series/" do
      before do
        @params = FactoryBot.attributes_for(:novel_series, owner: @user, novel_tag_name: "")
        request_post(@params)
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "正しいJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("この機能を使用するにはログインまたは、新規登録が必要です。").to eq json["errors"]
      end
      it "シリーズがDBに追加されないこと" do
        expect{request_post(@params)}.to change(NovelSeries, :count).by(0)
      end
    end

    # シリーズ編集
    describe "GET api/v1/novel_series/:id/edit" do
      before do
        @series = FactoryBot.create(
          :novel_series,
          :is_release,
          owner: @user,
        )
        get "/api/v1/novel_series/#{@series.id}/edit"
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "不正なJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("この機能を使用するにはログインまたは、新規登録が必要です。").to eq json["errors"]
      end
    end

    # シリーズ更新
    describe "PUT api/v1/novel_series/:id" do
      before do
        @updated_params = FactoryBot.attributes_for(:updated_series, owner: @user)
        @before_series = FactoryBot.create(
          :novel_series,
          owner: @user,
        )
        request_update({id: @before_series.id, params: @updated_params})
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "正しいJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("この機能を使用するにはログインまたは、新規登録が必要です。").to eq json["errors"]
      end
    end

    # シリーズ削除
    describe "DELETE api/v1/novel_series/:id" do
      before do
        @delete_series = FactoryBot.create(:delete_series, owner: @user)
        request_delete(@delete_series)
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "不正なJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("この機能を使用するにはログインまたは、新規登録が必要です。").to eq json["errors"]
      end
    end
  end


end
