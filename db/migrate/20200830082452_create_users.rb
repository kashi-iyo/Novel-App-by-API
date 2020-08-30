class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :nickname, null: false
      t.string :account_id, null: false
      t.string :email, null: false
      t.string :password_digest
      t.boolean :admin, null: false, default: false
      t.text :profile

      t.timestamps
    end
  end
end
