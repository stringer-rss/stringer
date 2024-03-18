# frozen_string_literal: true

class AddStoriesOrderToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :stories_order, :string, default: "desc"
  end
end
