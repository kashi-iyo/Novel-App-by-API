class AddAuthorToNovelSeries < ActiveRecord::Migration[5.2]
  def change
    add_column :novel_series, :author, :string
  end
end
