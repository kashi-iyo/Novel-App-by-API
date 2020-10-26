class RemoveCountFromNovelTags < ActiveRecord::Migration[5.2]
  def change
    remove_column :novel_tags, :count, :string
  end
end
