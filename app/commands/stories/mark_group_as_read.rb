require_relative "../../repositories/story_repository"

class MarkGroupAsRead
  KINDLING_GROUP_ID            = 1
  SPARKS_AND_KINDLING_GROUP_ID = 0

  def initialize(group_id, timestamp, repository = StoryRepository)
    @group_id  = group_id.to_i
    @repo      = repository
    @timestamp = timestamp
  end

  def mark_group_as_read
    if [SPARKS_AND_KINDLING_GROUP_ID, KINDLING_GROUP_ID].include? @group_id
      @repo.fetch_unread_by_timestamp(@timestamp).update_all(is_read: true)
    end
  end
end

