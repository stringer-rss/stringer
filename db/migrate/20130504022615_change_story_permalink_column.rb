class ChangeStoryPermalinkColumn < ActiveRecord::Migration
  def up
    change_column :stories, :permalink, :text
  end
end
