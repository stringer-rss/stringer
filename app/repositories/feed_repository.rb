class FeedRepository
  def self.update_last_fetched(feed, timestamp)
    feed.last_fetched = timestamp
    feed.save
  end
end