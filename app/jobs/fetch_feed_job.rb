# frozen_string_literal: true

FetchFeedJob =
  Struct.new(:feed_id) do
    def perform
      feed = FeedRepository.fetch(feed_id)
      FetchFeed.call(feed)
    end
  end
