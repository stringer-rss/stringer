class AddKeepUnreadToStories < ActiveRecord::Migration
  def change
    add_column :stories, :keep_unread, :boolean, default: false
  end
end
