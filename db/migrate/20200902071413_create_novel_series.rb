class CreateNovelSeries < ActiveRecord::Migration[5.2]
  def change
    create_table :novel_series do |t|
      t.string :series_title, null: false
      t.text :series_description
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
