# frozen_string_literal: true

class AddStatusToFeeds < ActiveRecord::Migration[4.2]
  def change
    add_column :feeds, :status, :int
  end
end
