# frozen_string_literal: true

class ChangeStoryPermalinkColumn < ActiveRecord::Migration[4.2]
  def up
    change_column :stories, :permalink, :text
  end

  def down
    change_column :stories, :permalink, :string
  end
end
