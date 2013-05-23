require_relative "../../repositories/story_repository"

class MarkAllAsRead
  def initialize(story_ids, repository = StoryRepository)
    @story_ids = story_ids
    @repo = repository
  end

  def mark_as_read
    @repo.fetch_by_ids_without_keep_unread(@story_ids).update_all(is_read: true)
  end
end