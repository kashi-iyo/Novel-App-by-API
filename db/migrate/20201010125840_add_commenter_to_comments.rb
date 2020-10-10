class AddCommenterToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :commenter, :string
  end
end
