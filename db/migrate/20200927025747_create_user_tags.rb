class CreateUserTags < ActiveRecord::Migration[5.2]
  def change
    create_table :user_tags do |t|
      t.string :user_tag_name, null: false

      t.timestamps
    end
  end
end
