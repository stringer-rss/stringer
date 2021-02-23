class UseTextDatatypeForTitleAndEntryId < ActiveRecord::Migration[4.2]
  def up
    change_column :stories, :title, :text
    change_column :stories, :entry_id, :text
  end

  def self.down
    change_column :stories, :title, :string
    change_column :stories, :entry_id, :string
  end
end
