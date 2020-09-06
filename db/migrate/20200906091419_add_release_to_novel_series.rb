class AddReleaseToNovelSeries < ActiveRecord::Migration[5.2]
  def change
    add_column :novel_series, :release, :boolean, default: false, null: false
  end
end
