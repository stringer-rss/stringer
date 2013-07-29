require_relative "../../repositories/feed_repository"

class MarkFeedAsRead
  def initialize(feed_id, timestamp, repository = FeedRepository)
    @feed_id   = feed_id.to_i
    @feed      = Feed.find(@feed_id)
    @repo      = repository
    @timestamp = timestamp
  end

  def mark_feed_as_read
    @feed.stories.update_all(is_read: true)
  end
end

