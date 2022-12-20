# frozen_string_literal: true

require_relative "../../repositories/story_repository"

class MarkAsRead
  def initialize(story_id)
    @story_id = story_id
  end

  def mark_as_read
    StoryRepository.fetch(@story_id).update!(is_read: true)
  end
end
