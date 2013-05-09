class AddUniqueConstraints < ActiveRecord::Migration
  def change
    add_index :stories, [:permalink, :feed_id], unique: true
    add_index :feeds, :url, unique: true
  end
end
