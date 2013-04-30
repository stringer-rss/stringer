class AddStatusToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :status, :int
  end
end
