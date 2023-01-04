# frozen_string_literal: true

class UpdateNilEntryIds < ActiveRecord::Migration[4.2]
  def up
    Story.where(entry_id: nil).each do |story|
      story.entry_id = story.permalink || story.id
      story.save
    end
  end

  def down
    # skip
  end
end
