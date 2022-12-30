# frozen_string_literal: true

class DropEmailFromUser < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :email
  end
end
