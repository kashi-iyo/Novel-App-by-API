class NovelTagMap < ApplicationRecord
  belongs_to :novel_series
  belongs_to :novel_tag
end
