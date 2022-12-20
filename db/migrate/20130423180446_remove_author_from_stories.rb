# frozen_string_literal: true

class RemoveAuthorFromStories < ActiveRecord::Migration[4.2]
  def up
    remove_column :stories, :author
  end
end
