# frozen_string_literal: true

class AddAdminToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :admin, :boolean, default: false

    set_first_user_as_admin

    change_column_null :users, :admin, false
  end

  private

  def set_first_user_as_admin
    first_user_id = connection.select_value("SELECT id FROM users ORDER BY id LIMIT 1")

    return unless first_user_id

    connection.update("UPDATE users SET admin = TRUE WHERE id = #{first_user_id}")
  end
end
