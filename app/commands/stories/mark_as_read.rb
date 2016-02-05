require_relative "../../repositories/story_repository"

class MarkAsRead
  def initialize(story_id, repository = StoryRepository)
    @story_id = story_id
    @repo = repository
  end

  def mark_as_read
    @repo.fetch(@story_id).update_attributes(is_read: true)
  end
end
