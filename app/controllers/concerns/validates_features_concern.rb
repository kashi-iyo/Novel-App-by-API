module ValidatesFeaturesConcern

    extend ActiveSupport::Concern

    # validates 認可用メソッド
    included do
        helper_method :release?, :authorized?, :check_existing?, :handle_unauthorized, :favorited_by?, :following?
    end

    #validates ログイン中のユーザーとdataのユーザーが一致するかをbool値で返す
    def authorized?(data)
        data_type = data[:data_type]
        @id = current_user.id
        if data_type === "user"
            data[:object][:id] === @id
        elsif data_type === "novel_for_create"
            data[:association_data][:user_id] === @id
        elsif data_type === "relationship"
            data[:association_data][:id] != @id
        else
            data[:object][:user_id] === @id
        end
    end

    #validates 存在をチェック
    def check_existing?(check_data)
        object = check_data[:object]
        params = check_data[:params]
        data_type = check_data[:data_type]
        case data_type
        when "relationship"
            if object.find_by(id: params).nil?
                return_not_present_data(data_type)
            else
                return object.find_by(id: params)
            end
        end
    end

    #validates releaseが真かどうか確認
    def release?(data)
        release = data[:object][:release]
        !!release || !release && authorized?(data)
    end

    #validates ユーザーがその小説をお気に入りしているかどうかをチェック
    def favorited_by?(novel_data)
        novel_data.novel_favorites.where(user_id: current_user.id).exists?
    end

    #validates ログインユーザーが当該ユーザーをフォローしているかどうかをチェック
    def following?(other_user)
        current_user.followings.include?(other_user)
    end

end