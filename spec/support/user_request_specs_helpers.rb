module UserRequestSpecsHelpers


    # ユーザーパラメータを生成
    def return_user_params(post_data)
        @params = FactoryBot.attributes_for(:user, post_data[:permit])
    end

    # 重複したデータを生成する
    def return_duplicate_params(permit)
        FactoryBot.create(:user, permit)
        @params = return_user_params({permit: permit })
    end
    # POSTリクエストを送信
    def request_post(user_params)
        post "/api/v1/users", params: {user: user_params}
    end

    # HTTPステータスの判定
    def expect_http_status(params, status)
        request_post(params)
        expect(response).to have_http_status(status)
    end

end