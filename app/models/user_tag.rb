class UserTag < ApplicationRecord

    validates :user_tag_name, presence: true
    validates :user_tag_name, length: { maximum: 50 }

    has_many :user_tag_maps, dependent: :destroy, foreign_key: :user_tag_id
    has_many :users, through: :user_tag_maps

    # そのタグを登録しているユーザー数を取得
    def self.tag_has_users_count(tags)
        count = tags.map {|tag|
            [tag.id, tag.users.count.to_s]
        }.to_h
        count.map do |k, v|
            tags.map do |tag|
                if tag.id === k
                    tag["count"] = v
                end
            end
        end
    end
end
