class UpdateStoriesUniqueConstraints < ActiveRecord::Migration
  def up
    remove_index :stories, [:permalink, :feed_id]
    add_index :stories, [:entry_id, :feed_id], unique: true, length: { permalink: 767 }
  end

  def down
    remove_index :stories, [:entry_id, :feed_id]
    add_index :stories, [:permalink, :feed_id], unique: true, length: { permalink: 767 }
  end
end
