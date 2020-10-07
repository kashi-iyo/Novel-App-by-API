class NovelTag < ApplicationRecord

    validates :novel_tag_name, presence: true
    # validates :novel_tag_name, uniquness: true

    has_many :novel_tag_maps, dependent: :destroy, foreign_key: :novel_tag_id
    has_many :novel_series, through: :novel_tag_maps

    # 特定のタグを登録しているシリーズの総数
    def self.tag_has_series_count(tags)
        count = tags.map {|tag|
            [tag.id, tag.novel_series.count.to_s]
        }.to_h
        count.map do |k, v|
            tags.map do |tag|
                if tag.id === k
                    tag["count"] = v
                end
            end
        end
    end

end
