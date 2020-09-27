class User < ApplicationRecord
    has_secure_password

    # 紐付け
    has_many :novel_series, dependent: :destroy
    has_many :novels, through: :novel_series, dependent: :destroy
    has_many :user_tag_maps, dependent: :destroy
    has_many :user_tags, through: :user_tag_maps

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
