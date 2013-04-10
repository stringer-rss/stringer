require_relative "fetch_feed"

class FetchFeeds
  def initialize(feeds)
    @feeds = feeds
  end

  def fetch_all
    @feeds.each do |feed|
      FetchFeed.new(feed).fetch
    end
  end
end