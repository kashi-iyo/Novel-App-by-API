class NovelSeries < ApplicationRecord
  # 並び替え
  default_scope { order(updated_at: :desc) }

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
  validates :user_id, presence: true

  # シリーズタグを作成
  def save_tag(sent_tags)
    # シリーズに紐付けられた現在存在するタグを取得する
    current_tags = self.novel_tags.pluck(:novel_tag_name) unless self.novel_tags.nil?
    # 現在データベースに存在するデータを取得する
    old_tags = current_tags - sent_tags
    # 現在データベースに存在しないデータだけを取り出す
    new_tags = sent_tags - current_tags

    old_tags.each do |old|
      # すでに存在するタグは削除してしまう
      self.novel_tags.delete NovelTag.find_by(novel_tag_name: old)
    end

    new_tags.each do |new|
      # 新しいタグは保存する
      new_novel_tag = NovelTag.find_or_create_by(novel_tag_name: new)
      self.novel_tags << new_novel_tag
    end
  end

end