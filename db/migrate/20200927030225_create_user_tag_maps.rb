class CreateUserTagMaps < ActiveRecord::Migration[5.2]
  def change
    create_table :user_tag_maps do |t|
      t.references :user, foreign_key: true
      t.references :user_tag, foreign_key: true

      t.timestamps
    end
  end
end
