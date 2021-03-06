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
    # フォロー相手
    has_many :relationships, foreign_key: "user_id", dependent: :destroy
    has_many :followings, through: :relationships, source: :follow
    # フォロワー
    has_many :passive_relationships, class_name: "Relationship", foreign_key: "follow_id", dependent: :destroy
    has_many :followers, through: :passive_relationships, source: :user

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

    # フォロー済みかどうか
    def following?(other_user)
        self.followings.include?(other_user)
    end

    # フォロー
    def follow(other_user)
        unless self === other_user
            self.relationships.find_or_create_by(follow_id: other_user.id)
        end
    end

    # フォロー解除
    def unfollow(other_user)
        relationship = self.relationships.find_by(follow_id: other_user.id)
        relationship.destroy if relationship
    end

end
