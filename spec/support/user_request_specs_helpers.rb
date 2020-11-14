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

    # 不正のJSONレスポンスを返すことを判定
    def expect_error_response(params, errors)
        request_post(params)
        expect(JSON.parse(response.body)).to eq(not_created_object(errors))
    end

    # DBに登録することを判定
    def expect_change_count(response_data, class_data)
        expect { response_data }.to change(class_data, :count).by(0)
    end

    # DBに登録しないことを判定
    def expect_not_change_count(response_data, class_data)
        expect { response_data }.to change(class_data, :count).by(0)
    end

end