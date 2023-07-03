# frozen_string_literal: true

class AddAdminToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :admin, :boolean

    User.first.update!(admin: true) if User.any?

    change_column_null :users, :admin, false
  end
end
