class UserTagMap < ApplicationRecord
  belongs_to :user
  belongs_to :user_tag

  MAX_TAGS_COUNT = 5
  validate :tags_count_limit
  private
    def tags_count_limit
      errors.add(:base, "追加できる趣味タグは #{MAX_TAGS_COUNT}個 までです。") if user.user_tag_maps.count >= MAX_TAGS_COUNT
    end
end
