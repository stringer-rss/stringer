class AddAliasToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :alias, :string
  end
end
