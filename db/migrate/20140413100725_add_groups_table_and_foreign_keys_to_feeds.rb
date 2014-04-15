class AddGroupsTableAndForeignKeysToFeeds < ActiveRecord::Migration
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
