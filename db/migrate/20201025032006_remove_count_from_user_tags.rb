class RemoveCountFromUserTags < ActiveRecord::Migration[5.2]
  def change
    remove_column :user_tags, :count, :string
  end
end
