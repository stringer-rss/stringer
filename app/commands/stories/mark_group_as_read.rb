require_relative "../../repositories/story_repository"

class MarkGroupAsRead
  def initialize(group_id, timestamp, repository = StoryRepository)
    @group_id  = group_id.to_i
    @repo      = repository
    @timestamp = timestamp
  end

  def mark_group_as_read
    @repo.fetch_unread_by_timestamp(@timestamp).update_all(is_read: true) if @group_id == 1
  end
end

