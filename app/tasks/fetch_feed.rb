require "feedjira"
require "httparty"

require_relative "../repositories/story_repository"
require_relative "../repositories/feed_repository"
require_relative "../commands/feeds/find_new_stories"

class FetchFeed
  def initialize(feed, parser: Feedjira, client: HTTParty, logger: nil)
    @feed = feed
    @parser = parser
    @client = client
    @logger = logger
  end

  def fetch
    raw_feed = fetch_raw_feed

    if raw_feed == 304
      feed_not_modified
    else
      feed_modified(raw_feed)
    end

    FeedRepository.set_status(:green, @feed)
  rescue StandardError => e
    FeedRepository.set_status(:red, @feed)

    @logger&.error "Something went wrong when parsing #{@feed.url}: #{e}"
  end

  private

  def fetch_raw_feed
    response = @client.get(@feed.url).to_s
    @parser.parse(response)
  end

  def feed_not_modified
    @logger&.info "#{@feed.url} has not been modified since last fetch"
  end

  def feed_modified(raw_feed)
    new_entries_from(raw_feed).each do |entry|
      StoryRepository.add(entry, @feed)
    end

    FeedRepository.update_last_fetched(@feed, raw_feed.last_modified)
  end

  def new_entries_from(raw_feed)
    finder = FindNewStories.new(raw_feed, @feed.id, @feed.last_fetched, latest_entry_id)
    finder.new_stories
  end

  def latest_entry_id
    return @feed.stories.first.entry_id unless @feed.stories.empty?
  end
end
