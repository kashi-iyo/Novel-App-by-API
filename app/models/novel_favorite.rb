class NovelFavorite < ApplicationRecord
  belongs_to :user
  belongs_to :novel
end
