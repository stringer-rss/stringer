# frozen_string_literal: true

require_relative "../../repositories/story_repository"

class MarkAsUnread
  def initialize(story_id)
    @story_id = story_id
  end

  def mark_as_unread
    StoryRepository.fetch(@story_id).update!(is_read: false)
  end
end
