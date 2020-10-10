class AddFavoriterToNovelFavorites < ActiveRecord::Migration[5.2]
  def change
    add_column :novel_favorites, :favoriter, :string
  end
end
