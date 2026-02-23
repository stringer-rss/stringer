# frozen_string_literal: true

class AddSettingsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :settings, :jsonb, default: {}, null: false
  end
end
