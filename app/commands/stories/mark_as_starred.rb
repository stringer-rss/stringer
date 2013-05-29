require_relative "../../repositories/story_repository"

class MarkAsStarred
  def initialize(story_id, repository = StoryRepository)
    @story_id = story_id
    @repo = repository
  end

  def mark_as_starred
    @repo.fetch(@story_id).update_attributes(is_starred: true)
  end
end

