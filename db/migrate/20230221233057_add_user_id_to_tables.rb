# frozen_string_literal: true

class AddUserIdToTables < ActiveRecord::Migration[7.0]
  def change
    add_reference :feeds, :user, index: true, foreign_key: true
    add_reference :groups, :user, index: true, foreign_key: true
  end
end
