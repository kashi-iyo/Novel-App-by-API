class User < ApplicationRecord
    has_secure_password

    # 紐付け
    # シリーズ
    has_many :novel_series, dependent: :destroy
    # 小説
    has_many :novels, through: :novel_series, dependent: :destroy
    # タグ
    has_many :user_tag_maps, dependent: :destroy
    has_many :user_tags, through: :user_tag_maps
    # お気に入り
    has_many :novel_favorites
    has_many :favorited_novels, through: :novel_favorites, source: :novel

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

end
