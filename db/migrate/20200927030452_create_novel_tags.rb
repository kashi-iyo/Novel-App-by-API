class CreateNovelTags < ActiveRecord::Migration[5.2]
  def change
    create_table :novel_tags do |t|
      t.string :novel_tag_name, null:false

      t.timestamps
    end
  end
end
