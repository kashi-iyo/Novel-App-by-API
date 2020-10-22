class User < ApplicationRecord
    has_secure_password

    # 紐付け
    # シリーズ
    has_many :novel_series, dependent: :destroy
    # 小説
    has_many :novels, through: :novel_series, dependent: :destroy
    has_many :novels, dependent: :destroy
    # タグ
    has_many :user_tag_maps, dependent: :destroy
    has_many :user_tags, through: :user_tag_maps
    # お気に入り
    has_many :novel_favorites, dependent: :destroy
    has_many :favorited_novels, through: :novel_favorites, source: :novel
    # コメント
    has_many :comments, dependent: :destroy

    # バリデーション
    validates :nickname, presence: true
    validates :nickname, uniqueness: true
    validates :nickname, length: { maximum: 30 }

    validates :account_id, presence: true
    validates :account_id, uniqueness: true
    validates :account_id, length: { maximum: 15 }

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, {presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }}

    validates :profile, length: { maximum: 200 }

    # 趣味タグを作成
    def save_user_tag(sent_tags)
        current_tags = self.user_tags.pluck(:user_tag_name) unless self.user_tags.nil?
        old_tags = current_tags - sent_tags
        new_tags = sent_tags - current_tags

        old_tags.each do |old|
        self.user_tags.delete UserTag.find_by(user_tag_name: old)
        end

        new_tags.each do |new|
        new_user_tag = UserTag.find_or_create_by(user_tag_name: new)
            self.user_tags << new_user_tag
        end
    end

    # # 編集用の趣味タグデータを取得
    # def edit_user_tags
    #     tags = self.user_tags
    #     @tags = tags.map do |tag|
    #         [tag.user_tag_name]
    #     end
    #     user_tags = []
    #     user_tags.push(@tags)
    #     user_tags.flatten!
    # end

end
