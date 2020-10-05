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

  # タグを作成
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

  # シリーズが所有する小説のカウント
  def self.count_in_series(all_series)
    @novels_count = all_series.map{ |series|
      [series.id, series.novels.count.to_s]
    }.to_h
    @novels_count.each do |k, v|
      all_series.each do |series|
          if series.id === k
              series["count"] = v
          end
      end
    end
  end

  # シリーズが所有するタグを取得
  def tags_in_series
    series_tags = self.novel_tags
    return series_tags.map{ |tags|
        [tags]
    }.flatten
  end

  # 編集用のタグデータを取得
  def edit_tags
    tags = self.tags_in_series
    @tags = tags.map do |tag|
        [tag.novel_tag_name]
    end
    series_tags = []
    series_tags.push(@tags)
    series_tags.flatten!
  end

end