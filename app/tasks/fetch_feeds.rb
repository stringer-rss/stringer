# frozen_string_literal: true

require "thread/pool"

class FetchFeeds
  def self.enqueue(feeds)
    new(feeds).prepare_to_delay.delay.fetch_all
  end

  def initialize(feeds)
    @feeds = feeds
    @feeds_ids = []
  end

  def fetch_all
    pool = Thread.pool(10)

    if @feeds.blank? && @feeds_ids.present?
      @feeds = FeedRepository.fetch_by_ids(@feeds_ids)
    end

    @feeds.each do |feed|
      pool.process do
        FetchFeed.call(feed)

        ActiveRecord::Base.connection.close
      end
    end

    pool.shutdown
  end

  def prepare_to_delay
    @feeds_ids = @feeds.map(&:id)
    @feeds = []
    self
  end
end
