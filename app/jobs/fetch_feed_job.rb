class FetchFeedJob < Struct.new(:feed_id)
  def perform
    feed = FeedRepository.fetch(feed_id)
    FetchFeed.new(feed).fetch
  end
end
