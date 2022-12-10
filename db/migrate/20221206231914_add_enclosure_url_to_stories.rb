# frozen_string_literal: true

class AddEnclosureUrlToStories < ActiveRecord::Migration[4.2]
  def change
    add_column(:stories, :enclosure_url, :string)
  end
end
