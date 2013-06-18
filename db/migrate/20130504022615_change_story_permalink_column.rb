class ChangeStoryPermalinkColumn < ActiveRecord::Migration
  def up
    change_column :stories, :permalink, :text
  end

  def down
    change_column :stories, :permalink, :string
  end
end
