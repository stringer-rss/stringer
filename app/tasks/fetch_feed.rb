require "feedjira"

require_relative "../repositories/story_repository"
require_relative "../repositories/feed_repository"
require_relative "../commands/feeds/find_new_stories"

class FetchFeed

  USER_AGENT = "Stringer (https://github.com/swanson/stringer)"

  def initialize(feed, feed_parser = Feedjira::Feed, logger = nil)
    @feed = feed
    @parser = feed_parser
    @logger = logger
  end

  def fetch
    begin
      raw_feed = @parser.fetch_and_parse(@feed.url, user_agent: USER_AGENT, if_modified_since: @feed.last_fetched, timeout: 30, max_redirects: 2)

      if raw_feed == 304
        @logger.info "#{@feed.url} has not been modified since last fetch" if @logger
      else
        new_entries_from(raw_feed).each do |entry|
          StoryRepository.add(entry, @feed)
        end

        FeedRepository.update_last_fetched(@feed, raw_feed.last_modified)
      end

      FeedRepository.set_status(:green, @feed)
    rescue Exception => ex
      FeedRepository.set_status(:red, @feed)

      @logger.error "Something went wrong when parsing #{@feed.url}: #{ex}" if @logger
    end
  end

  private
  def new_entries_from(raw_feed)
    finder = FindNewStories.new(raw_feed, @feed.last_fetched, latest_entry_id)
    finder.new_stories
  end

  def latest_entry_id
    return @feed.stories.first.entry_id unless @feed.stories.empty?
  end
end
