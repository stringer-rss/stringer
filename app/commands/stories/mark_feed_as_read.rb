require_relative "../../repositories/story_repository"

class MarkFeedAsRead
  def initialize(feed_id, timestamp, repository = StoryRepository)
    @feed_id  = feed_id.to_i
    @repo      = repository
    @timestamp = timestamp
  end

  def mark_feed_as_read
    @repo.fetch_unread_for_feed_by_timestamp(@feed_id, @timestamp).update_all(is_read: true)
  end
end
