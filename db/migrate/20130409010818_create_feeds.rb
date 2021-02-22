class CreateFeeds < ActiveRecord::Migration[4.2]
  def change
    create_table :feeds do |t|
      t.string :name
      t.string :url
      t.timestamp :last_fetched

      t.timestamps
    end
  end
end
