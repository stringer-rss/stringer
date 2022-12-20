# frozen_string_literal: true

require_relative "../../repositories/story_repository"

class MarkAsStarred
  def initialize(story_id)
    @story_id = story_id
  end

  def mark_as_starred
    StoryRepository.fetch(@story_id).update!(is_starred: true)
  end
end
