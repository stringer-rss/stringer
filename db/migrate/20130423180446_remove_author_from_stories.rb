class RemoveAuthorFromStories < ActiveRecord::Migration
  def change
    remove_column :stories, :author
  end
end
