module ExpectHelpers

    def expect_save_ok(response)
        json = JSON.parse(response.body)
        expect("正常に保存されました。").to eq json["successful"]
    end

    def expect_update_ok(response)
        json = JSON.parse(response.body)
        expect("正常に編集が完了しました。").to eq json["successful"]
    end

    def expect_delete_ok(response)
        json = JSON.parse(response.body)
        expect("正常に削除されました。").to eq json["successful"]
    end

    def expect_can_not_access(response)
        json = JSON.parse(response.body)
        expect("アクセス権限がありません。").to eq json["errors"]
    end

    def expect_need_auth(response)
        json = JSON.parse(response.body)
        expect("この機能を使用するにはログインまたは、新規登録が必要です。").to eq json["errors"]
    end

    def expect_can_not_be_blank(response, value)
        json = JSON.parse(response.body)
        expect(["#{value} can't be blank"]).to eq json["errors"]
    end

# NovelSeries request specsにおけるexpect
    # 配列の存在をチェック
        # 1件のシリーズ内の配列の存在をチェック
        def expect_series_length(response, length)
            json = JSON.parse(response.body)
            expect(length).to eq json["object"]["series"].length
        end
        # 複数シリーズのデータ内の配列の存在をチェック
        def expect_multiple_series_length(response, length, key)
            json = JSON.parse(response.body)
            json["object"]["series"].map do |series|
                expect(length).to eq series["#{key}"].length
            end
        end
    # シリーズに紐付けされたデータの有無をチェック
    def expect_series_include_items(response, key)
        json = JSON.parse(response.body)
        json["object"]["series"].map do |series|
            expect(1).to eq series["#{key}"]
        end
    end
    # シリーズの順番をチェック
    def expect_series_order(response, series_id)
        json = JSON.parse(response.body)["object"]["series"].first
        expect(series_id).to eq json["series"]["id"]
    end
    # シリーズの持つ値をチェック
    def expect_series_value(response, value, key)
        json = JSON.parse(response.body)
        expect(value).to eq json["object"]["series"]["#{key}"]
    end
    # オブジェクトの持つ値をチェック
    def expect_object_value(response, value, key)
        json = JSON.parse(response.body)
        expect(value).to eq json["object"]["#{key}"]
    end

    # Relationship request specsにおけるexpect
    def expect_relationship_users_length(response, length)
        json = JSON.parse(response.body)
        expect(length).to eq json["object"]["users"].length
    end

    def expect_return_current_user(response, user)
        json = JSON.parse(response.body)
        expect(user.nickname).to eq json["object"]["user"]
    end

end