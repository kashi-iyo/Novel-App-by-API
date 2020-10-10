class NovelTagMap < ApplicationRecord
  belongs_to :novel_series
  belongs_to :novel_tag

  # バリデーション
  validates :novel_series_id, presence: true
  validates :novel_tag_id, presence: true
end
