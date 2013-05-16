require 'thread/pool'
require_relative "fetch_feed"

class FetchFeeds
  def initialize(feeds)
    @feeds = feeds
  end

  def fetch_all
    pool = Thread.pool(10)

    @feeds.each do |feed|
      pool.process do
        FetchFeed.new(feed).fetch
      end
    end

    pool.shutdown
  end

  def self.enqueue(feeds)
    self.new(feeds).delay.fetch_all
  end
end
