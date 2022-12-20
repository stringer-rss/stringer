# frozen_string_literal: true

class AddSetupCompleteToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :setup_complete, :boolean
  end
end
