class Novel < ApplicationRecord
  # 紐付け
  # ユーザー
  belongs_to :user
  # シリーズ
  belongs_to :novel_series
  # お気に入り
  has_many :novel_favorites, dependent: :destroy
  # コメント
  has_many :comments, dependent: :destroy

  # バリデーション
  validates :novel_title, presence: true
  validates :novel_title, length: { maximum: 50 }
  validates :novel_description, length: { maximum: 300 }
  validates :novel_content, presence: true
  validates :author, presence: true
  validates :user_id, presence: true
  validates :novel_series_id, presence: true

  # ユーザーがその小説をお気に入りしているかどうかをチェック
  def favorited_by?(current_user)
    self.novel_favorites.where(user_id: current_user.id).exists?
  end
end
