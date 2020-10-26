class UserTag < ApplicationRecord

    validates :user_tag_name, presence: true
    validates :user_tag_name, length: { maximum: 50 }

    has_many :user_tag_maps, dependent: :destroy, foreign_key: :user_tag_id
    has_many :users, through: :user_tag_maps

end
