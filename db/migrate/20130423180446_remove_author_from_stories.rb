class RemoveAuthorFromStories < ActiveRecord::Migration
  def up
    remove_column :stories, :author
  end
end
