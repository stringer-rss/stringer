class AddEntryIdToStories < ActiveRecord::Migration
  def change
    add_column :feeds, :entry_id, :string
  end
end
