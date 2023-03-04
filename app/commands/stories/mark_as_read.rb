# frozen_string_literal: true

module MarkAsRead
  def self.call(story_id)
    StoryRepository.fetch(story_id).update!(is_read: true)
  end
end
