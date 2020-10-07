class Novel < ApplicationRecord
  # 紐付け
  belongs_to :user
  belongs_to :novel_series
  has_many :novel_favorites

  # バリデーション
  validates :novel_title, presence: true
  validates :novel_title, length: { maximum: 50 }
  validates :novel_description, length: { maximum: 300 }
  validates :novel_content, presence: true
  validates :author, presence: true

  # ユーザーがその小説をお気に入りしているかどうかをチェック
  def favorited_by?(current_user)
    self.novel_favorites.where(user_id: current_user.id).exists?
  end
end
