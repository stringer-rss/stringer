class ChangeStoryPermalinkColumn < ActiveRecord::Migration
  def change
    change_column :stories, :permalink, :text
  end
end
