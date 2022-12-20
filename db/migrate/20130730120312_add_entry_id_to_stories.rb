# frozen_string_literal: true

class AddEntryIdToStories < ActiveRecord::Migration[4.2]
  def change
    add_column :stories, :entry_id, :string
  end
end
