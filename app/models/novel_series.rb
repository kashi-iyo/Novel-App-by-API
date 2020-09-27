class NovelSeries < ApplicationRecord
  # 並び替え
  default_scope { order(created_at: :desc) }

  # 紐付け
  belongs_to :user
  has_many :novels, dependent: :destroy
  has_many :novel_tag_maps, dependent: :destroy
  has_many :novel_tags, through: :novel_tag_maps

  # バリデーション
  validates :series_title, presence: true
  # validates :series_title, uniquness: true
  validates :series_title, length: { maximum: 50 }
  validates :series_description, length: { maximum: 300 }
  validates :author, presence: true

  # インスタンスメソッド
  def save_tag(sent_tags)
    current_tags = self.novel_tags.pluck(:novel_tag_name) unless self.novel_tags.nil?
    old_tags = current_tags - sent_tags
    new_tags = sent_tags - current_tags

    old_tags.each do |old|
      self.novel_tags.delete NovelTag.find_by(novel_tag_name: old)
    end

    new_tags.each do |new|
      new_novel_tag = NovelTag.find_or_create_by(novel_tag_name: new)
      self.novel_tags << new_novel_tag
    end
  end

  # def self.push_novel_count
  #   NovelSeries.each do |series|
  #     novel = Novel.find_by(novel_series_id: series.id)
  #     self << novel
  #   end
  # end
end