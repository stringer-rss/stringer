# frozen_string_literal: true

class UpdateUniqueIndexes < ActiveRecord::Migration[7.0]
  def change
    remove_index :feeds, :url
    add_index :feeds, [:url, :user_id], unique: true
    add_index :groups, [:name, :user_id], unique: true
  end
end
