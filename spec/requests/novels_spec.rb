require 'rails_helper'

RSpec.describe "Novels", type: :request do

  context "認証済みユーザーの場合" do
    before do
      # series: @series / novel: @novel
      login()
    end
    # 小説詳細
    describe "GET /api/v1/novel_series/:novel_series_id/novels/:id" do
      before do
        get_show_novel(@user)
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "正常なJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect(@novel.id).to eq json["object"]["novel"]["id"]
      end
    end

    # 小説作成
    describe "POST /api/v1/novel_series/:novel_series_id/novels" do
      context "自身のシリーズに対して作成した場合" do
        before do
          create_novel_attributes(@user)
          request_novel_post(@series.id, @params)
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "正常なJSONレスポンスを返すこと" do
          json = JSON.parse(response.body)
          expect("正常に保存されました。").to eq json["successful"]
        end
        it "DBにデータが登録されること" do
          expect{request_novel_post(@series.id, @params)}.to change(Novel, :count).by(1)
        end
      end
      context "異なるユーザーのシリーズに対して作成した場合" do
        before do
          @other_user = FactoryBot.create(:user)
          create_novel_attributes(@other_user)
          request_novel_post(@series.id, @params)
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "不正なJSONレスポンスを返すこと" do
          json = JSON.parse(response.body)
          expect("アクセス権限がありません。").to eq json["errors"]
        end
        it "DBにデータが登録されないこと" do
          expect{request_novel_post(@series.id, @params)}.to change(Novel, :count).by(0)
        end
      end
    end

    # 小説編集
    describe "GET /api/v1/novel_series/:novel_series_id/novels/:id/edit" do
      context "自身の小説を取得しようとした場合" do
        before do
          get_edit_novel(@user)
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "正常なJSONレスポンスを返すこと" do
          json = JSON.parse(response.body)
          expect(@novel.id).to eq json["object"]["novel_id"]
        end
      end
      context "異なるユーザーの小説を編集しようとした場合" do
        before do
          @other_user = FactoryBot.create(:user)
          get_edit_novel(@other_user)
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

    # 小説更新
    describe "PUT /api/v1/novel_series/:novel_series_id/novels/:id" do
      context "自身の小説を更新しようとした場合" do
        before do
          # 元のシリーズと小説を作成（@series, @noveを取得）
          create_novel_data(@user)
          # 変更したいパラメータを作成（@paramsを取得）
          create_novel_attributes(@user)
          # 更新
          request_novel_update(@series.id, @novel.id, @params)
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "正常なJSONレスポンスを返すこと" do
          json = JSON.parse(response.body)
          expect("正常に編集が完了しました。").to eq json["successful"]
        end
      end
      context "異なるユーザーの小説を更新しようとした場合" do
        before do
          @other_user = FactoryBot.create(:user)
          # 他のユーザーのシリーズと小説を作成（@series, @noveを取得）
          create_novel_data(@other_user)
          # 更新用データ
          create_novel_attributes(@user)
          request_novel_update(@series.id, @novel.id, @params)
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

    # 小説削除
    describe "DELETE /api/v1/novel_series/:novel_series_id/novels/:id" do
      context "自身の小説を削除しようとした場合" do
        before do
          # 元のシリーズと小説を作成（@series, @noveを取得）
          create_novel_data(@user)
          # 更新
          request_novel_delete(@series.id, @novel.id)
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "正常なJSONレスポンスを返すこと" do
          json = JSON.parse(response.body)
          expect("正常に削除されました。").to eq json["successful"]
        end
      end
      context "異なるユーザーの小説を削除しようとした場合" do
        before do
          @other_user = FactoryBot.create(:user)
          # 他のユーザーのシリーズと小説を作成（@series, @noveを取得）
          create_novel_data(@other_user)
          request_novel_delete(@series.id, @novel.id)
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "不正なJSONレスポンスを返すこと" do
          json = JSON.parse(response.body)
          expect("アクセス権限がありません。").to eq json["errors"]
        end
        it "DBからデータが削除されないこと" do
          expect{request_novel_delete(@series.id,  @novel.id)}.to change(Novel, :count).by(0)
        end
      end
    end
  end

  context "未認証ユーザーの場合" do
    before do
      @user = FactoryBot.create(:user)
      delete "/logout"
    end
    # 小説詳細
    describe "GET /novels" do
      context "小説が公開されている場合" do
        before do
          get_show_novel(@user)
        end
        it "200を返すこと" do
          expect(response.status).to eq 200
        end
        it "正常なJSONレスポンスを返すこと" do
          json = JSON.parse(response.body)
          expect(@novel.id).to eq json["object"]["novel"]["id"]
        end
      end
      context "小説が非公開の場合" do
        before do
          get_not_show_unrelease_novel(@user)
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

    # 小説作成
    describe "POST /api/v1/novel_series/:novel_series_id/novels" do
      before do
        create_novel_attributes(@user)
        request_novel_post(@series.id, @params)
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "不正なJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("この機能を使用するにはログインまたは、新規登録が必要です。").to eq json["errors"]
      end
    end

    # 小説編集
    describe "GET /api/v1/novel_series/:novel_series_id/novels/:id/edit" do
      before do
        get_edit_novel(@user)
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "不正なJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("この機能を使用するにはログインまたは、新規登録が必要です。").to eq json["errors"]
      end
    end

    # 小説更新
    describe "PUT /api/v1/novel_series/:novel_series_id/novels/:id" do
      before do
        @other_user = FactoryBot.create(:user)
        # ユーザーのシリーズと小説を作成（@series, @noveを取得）
        create_novel_data(@user)
        # 更新用データ
        create_novel_attributes(@other_user)
        request_novel_update(@series.id, @novel.id, @params)
      end
      it "200を返すこと" do
        expect(response.status).to eq 200
      end
      it "不正なJSONレスポンスを返すこと" do
        json = JSON.parse(response.body)
        expect("この機能を使用するにはログインまたは、新規登録が必要です。").to eq json["errors"]
      end
    end

    # 小説削除
    describe "DELETE /api/v1/novel_series/:novel_series_id/novels/:id" do
      before do
        # 元のシリーズと小説を作成（@series, @noveを取得）
        create_novel_data(@user)
        # 更新
        request_novel_delete(@series.id, @novel.id)
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
