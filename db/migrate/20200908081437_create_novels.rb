class CreateNovels < ActiveRecord::Migration[5.2]
  def change
    create_table :novels do |t|
      t.string :novel_title, null: false
      t.text :novel_description
      t.text :novel_content, null: false
      t.string :author, null: false
      t.boolean :release, default: false, null: false
      t.references :user, foreign_key: true, null: false
      t.references :novel_series, foreign_key: true, null: false

      t.timestamps
    end
  end
end
