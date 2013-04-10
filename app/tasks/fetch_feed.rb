require "feedzirra"
require_relative "../repositories/story_repository"
require_relative "../repositories/feed_repository"

class FetchFeed
  def initialize(feed, feed_parser = Feedzirra::Feed)
    @feed = feed
    @parser = feed_parser
  end

  def fetch
    result = @parser.fetch_and_parse(@feed.url)

    unless result.last_modified < @feed.last_fetched
      FeedRepository.update_last_fetched(@feed, result.last_modified)

      result.entries.each do |entry|
        StoryRepository.add(entry, @feed) if is_new?(entry)
      end
    end

    result
  end

  private
  def is_new?(entry)
    entry.published > @feed.last_fetched
  end
end