class NovelSeries < ApplicationRecord
  default_scope { order(created_at: :desc) }

  belongs_to :user

  validates :series_title, presence: true
  validates :series_title, length: { maximum: 50 }

  validates :series_description, length: { maximum: 300 }
end
