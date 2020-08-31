class User < ApplicationRecord
    has_secure_password

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
