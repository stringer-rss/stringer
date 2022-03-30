require_relative "../../repositories/story_repository"

class MarkAsUnstarred
  def initialize(story_id)
    @story_id = story_id
  end

  def mark_as_unstarred
    StoryRepository.fetch(@story_id).update!(is_starred: false)
  end
end
