class AddCountToNovelTags < ActiveRecord::Migration[5.2]
  def change
    add_column :novel_tags, :count, :string
  end
end
