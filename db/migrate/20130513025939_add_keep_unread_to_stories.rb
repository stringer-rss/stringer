class AddKeepUnreadToStories < ActiveRecord::Migration[4.2]
  def change
    add_column :stories, :keep_unread, :boolean, default: false
  end
end
