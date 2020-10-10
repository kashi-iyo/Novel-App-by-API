class Comment < ApplicationRecord

  default_scope { order(created_at: :desc) }

  belongs_to :user
  belongs_to :novel

  # バリデーション
  validates :content, length: { maximum: 200 }
  validates :content, presence: true
  validates :user_id, presence: true
  validates :novel_id, presence: true
  validates :commenter, presence: true
end
