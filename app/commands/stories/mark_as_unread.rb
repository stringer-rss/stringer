# frozen_string_literal: true

module MarkAsUnread
  def self.call(story_id)
    StoryRepository.fetch(story_id).update!(is_read: false)
  end
end
