class AddUserModel < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest

      t.timestamps
    end
  end
end
