class CreateNovelTagMaps < ActiveRecord::Migration[5.2]
  def change
    create_table :novel_tag_maps do |t|
      t.references :novel_series, foreign_key: true
      t.references :novel_tag, foreign_key: true

      t.timestamps
    end
  end
end
