# frozen_string_literal: true

class AddUserModel < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest

      t.timestamps null: false
    end
  end
end
