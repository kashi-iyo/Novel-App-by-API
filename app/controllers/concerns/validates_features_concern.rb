module ValidatesFeaturesConcern

    extend ActiveSupport::Concern

    # validates 認可用メソッド
    included do
        helper_method :release?, :authorized?, :handle_unauthorized, :favorited_by?
    end

    #validates ログイン中のユーザーとdataのユーザーが一致するかをbool値で返す
    def authorized?(data, data_type)
        if data_type === "user"
            data[:id] === current_user.id
        elsif data_type === "novel_for_create"
            data[:association_data][:user_id] === current_user.id
        else
            data[:object][:user_id] === current_user.id
        # else
        #     data[:user_id] === current_user.id
        end
    end

    #validates releaseが真かどうか確認
    def release?(data)
        !!data[:release] || !data[:release] && authorized?(data)
    end

    #validates ユーザーがその小説をお気に入りしているかどうかをチェック
    def favorited_by?(novel_data)
        novel_data.novel_favorites.where(user_id: current_user.id).exists?
    end

end