class CreateNovelFavorites < ActiveRecord::Migration[5.2]
  def change
    create_table :novel_favorites do |t|
      t.references :user, foreign_key: true
      t.references :novel, foreign_key: true

      t.timestamps
    end
  end
end
