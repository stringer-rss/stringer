require_relative "../models/feed"

class FeedRepository
  def self.update_last_fetched(feed, timestamp)
    feed.last_fetched = timestamp
    feed.save
  end

  def self.delete(feed_id)
    Feed.destroy(feed_id)
  end
end