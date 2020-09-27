class ChangeProfileOfUsers < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :profile, :string, default: ""
  end
end
