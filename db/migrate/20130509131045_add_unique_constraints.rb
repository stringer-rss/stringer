# frozen_string_literal: true

class AddUniqueConstraints < ActiveRecord::Migration[4.2]
  def change
    add_index :stories, [:permalink, :feed_id], unique: true
    add_index :feeds, :url, unique: true
  end
end
