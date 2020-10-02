class NovelTag < ApplicationRecord

    validates :novel_tag_name, presence: true
    # validates :novel_tag_name, uniquness: true

    has_many :novel_tag_maps, dependent: :destroy, foreign_key: :novel_tag_id
    has_many :novel_series, through: :novel_tag_maps
end
