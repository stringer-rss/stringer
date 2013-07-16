require "feedzirra"

require_relative "../repositories/story_repository"
require_relative "../repositories/feed_repository"
require_relative "../commands/feeds/find_new_stories"

class FetchFeed
  def initialize(feed, feed_parser = Feedzirra::Feed, logger = nil)
    @feed = feed
    @parser = feed_parser
    @logger = logger
  end

  def fetch
    begin
      raw_feed = @parser.fetch_and_parse(@feed.url, user_agent: "Stringer", if_modified_since: @feed.last_fetched)

      new_entries_from(raw_feed).each do |entry|
        StoryRepository.add(entry, @feed)
      end

      FeedRepository.update_last_fetched(@feed, raw_feed.last_modified)
      FeedRepository.set_status(:green, @feed)
    rescue Exception => ex
      FeedRepository.set_status(:red, @feed)

      @logger.error "Something went wrong when parsing #{@feed.url}: #{ex}" if @logger
    end
  end

  private
  def new_entries_from(raw_feed)
    finder = FindNewStories.new(raw_feed, @feed.last_fetched, latest_url)
    finder.new_stories
  end

  def latest_url
    return @feed.stories.first.permalink unless @feed.stories.empty?
  end
end
