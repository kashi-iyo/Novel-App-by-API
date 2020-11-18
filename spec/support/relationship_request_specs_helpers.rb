module RelationshipRequestSpecsHelpers

    def request_post_relationship(user)
        post "/api/v1/relationships", params: {relationship: {follow_id: user.id}}
    end

    def create_multiple_relationships(pass_data)
        # 4人のユーザーを生成
        users = FactoryBot.create_list(:user, 4)
        users.map do |user|
            case pass_data[:type]
            # ログインユーザーがフォローしているユーザーを得る
            when "followings"
                FactoryBot.create(
                    :relationship,
                    user_id: pass_data[:user].id, #ログインユーザーが入る
                    follow_id: user.id
                )
            # ログインユーザーのフォロワーを得る
            when "followers"
                FactoryBot.create(
                    :relationship,
                    user_id: user.id,
                    follow_id: pass_data[:user].id, #ログインユーザーが入る
                )
            end
        end
    end
end