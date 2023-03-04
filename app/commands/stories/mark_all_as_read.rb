# frozen_string_literal: true

module MarkAllAsRead
  def self.call(story_ids)
    StoryRepository.fetch_by_ids(story_ids).update_all(is_read: true)
  end
end
