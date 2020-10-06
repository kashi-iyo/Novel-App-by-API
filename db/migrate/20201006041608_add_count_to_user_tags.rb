class AddCountToUserTags < ActiveRecord::Migration[5.2]
  def change
    add_column :user_tags, :count, :string
  end
end
