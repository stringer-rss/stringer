# frozen_string_literal: true

class AddGroupStoriesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :group_stories, :boolean, default: false, null: false
  end
end
