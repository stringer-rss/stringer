class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.string :name
      t.string :url
      t.timestamp :last_fetched

      t.timestamps
    end
  end
end
