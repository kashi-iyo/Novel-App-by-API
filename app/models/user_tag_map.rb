class UserTagMap < ApplicationRecord
  belongs_to :user
  belongs_to :user_tag

  # バリデーション
  validates :user_id, presence: true
  validates :user_tag_id, presence: true

end
