# frozen_string_literal: true

class AddUsernameToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :username, :string
    add_index :users, :username, unique: true

    set_default_username

    change_column_null :users, :username, false
  end

  private

  def set_default_username
    first_user_id = connection.select_value("SELECT id FROM users ORDER BY id LIMIT 1")

    return unless first_user_id

    connection.update("UPDATE users SET username = 'stringer' WHERE id = #{first_user_id}")
  end
end
