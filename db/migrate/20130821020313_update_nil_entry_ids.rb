class UpdateNilEntryIds < ActiveRecord::Migration
  def up
    Story.where(entry_id: nil).each do |story|
      story.entry_id = story.permalink || story.id
      story.save
    end
  end

  def self.down
    #skip
  end
end
