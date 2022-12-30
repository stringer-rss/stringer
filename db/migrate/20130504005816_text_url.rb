# frozen_string_literal: true

class TextUrl < ActiveRecord::Migration[4.2]
  def up
    change_column :feeds, :url, :text
  end

  def down
    change_column :feeds, :url, :string
  end
end
