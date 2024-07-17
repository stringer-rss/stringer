# frozen_string_literal: true

class AddNullFalseToAssociations < ActiveRecord::Migration[7.0]
  def change
    update_null_foreign_keys

    change_column_null :feeds, :user_id, false
    change_column_null :groups, :user_id, false
    change_column_null :stories, :feed_id, false
  end

  private

  def update_null_foreign_keys
    first_user_id = connection.select_value("SELECT id FROM users ORDER BY id LIMIT 1")

    return unless first_user_id

    connection.update("UPDATE feeds SET user_id = #{first_user_id} WHERE user_id IS NULL")
    connection.update("UPDATE groups SET user_id = #{first_user_id} WHERE user_id IS NULL")
  end
end
