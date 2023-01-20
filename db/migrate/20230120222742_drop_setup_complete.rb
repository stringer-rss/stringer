# frozen_string_literal: true

class DropSetupComplete < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :setup_complete, :boolean
  end
end
