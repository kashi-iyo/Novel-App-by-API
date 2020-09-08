class NovelSeries < ApplicationRecord
  # 並び替え
  default_scope { order(created_at: :desc) }

  # 紐付け
  belongs_to :user
  has_many :novels, dependent: :destroy

  # バリデーション
  validates :series_title, presence: true
  validates :series_title, uniquness: true
  validates :series_title, length: { maximum: 50 }
  validates :series_description, length: { maximum: 300 }
  validates :author, presence: true
  validates :release, presence: true
end