class AddUserModel < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest

      t.string :superfeedr_host
      t.string :superfeedr_username
      t.string :superfeedr_password
      
      t.timestamps
    end
  end
end
