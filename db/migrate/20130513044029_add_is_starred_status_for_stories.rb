class AddIsStarredStatusForStories < ActiveRecord::Migration[4.2]
  def change
    add_column :stories, :is_starred, :boolean, default: false
  end
end
