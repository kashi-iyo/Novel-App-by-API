class RemoveCountFromNovelSeries < ActiveRecord::Migration[5.2]
  def change
    remove_column :novel_series, :count, :string
  end
end
