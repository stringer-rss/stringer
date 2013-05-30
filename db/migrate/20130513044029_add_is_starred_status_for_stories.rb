class AddIsStarredStatusForStories < ActiveRecord::Migration
  def change
    add_column :stories, :is_starred, :boolean, default: false
  end
end
