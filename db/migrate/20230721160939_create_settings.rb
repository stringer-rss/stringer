# frozen_string_literal: true

class CreateSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :settings do |t|
      t.string :type, null: false, index: { unique: true }
      t.jsonb :data, null: false, default: {}

      t.timestamps
    end
  end
end
