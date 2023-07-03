# frozen_string_literal: true

class AddNullFalseToAssociations < ActiveRecord::Migration[7.0]
  def change
    if User.any?
      Feed.where(user: nil).update_all(user_id: User.first.id)
      Group.where(user: nil).update_all(user_id: User.first.id)
    end

    change_column_null :feeds, :user_id, false
    change_column_null :groups, :user_id, false
    change_column_null :stories, :feed_id, false
  end
end
