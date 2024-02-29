# frozen_string_literal: true

class AddDefaultToStories < ActiveRecord::Migration[7.1]
  def change
    change_column_default :stories, :is_read, from: nil, to: false
  end
end
