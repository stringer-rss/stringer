# frozen_string_literal: true

class AddGroupsTableAndForeignKeysToFeeds < ActiveRecord::Migration[4.2]
  def up
    create_table :groups do |t|
      t.string :name, null: false
      t.timestamps null: false
    end
    add_column :feeds, :group_id, :integer
  end

  def down
    drop_table :groups
    remove_column :feeds, :group_id
  end
end
