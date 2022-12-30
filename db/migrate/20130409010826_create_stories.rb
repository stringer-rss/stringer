# frozen_string_literal: true

class CreateStories < ActiveRecord::Migration[4.2]
  def change
    create_table :stories do |t|
      t.string :title
      t.string :permalink
      t.text :body

      t.references :feed

      t.timestamps null: false
    end
  end
end
