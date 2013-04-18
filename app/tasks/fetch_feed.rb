require "feedzirra"

require_relative "../repositories/story_repository"
require_relative "../repositories/feed_repository"

class FetchFeed
  def initialize(feed, feed_parser = Feedzirra::Feed)
    @feed = feed
    @parser = feed_parser
  end

  def fetch
    begin
      updated_feed = rebuild_feed

      updated_feed.new_entries.each do |entry|
        StoryRepository.add(entry, @feed) if is_new?(entry)
      end

      FeedRepository.update_last_fetched(@feed, updated_feed.last_modified)
    rescue Exception => ex
      puts "Something went wrong when parsing #{@feed.url}"
    end

    updated_feed
  end

  private
  def rebuild_feed
    new_feed = Feedzirra::Parser::RSS.new
    new_feed.feed_url = @feed.url
    new_feed.last_modified = @feed.last_fetched

    unless @feed.stories.empty?
      last_entry = Feedzirra::Parser::RSSEntry.new
      last_entry.url = @feed.stories.first.permalink

      new_feed.entries << last_entry
    end

    @parser.update(new_feed)
  end

  def is_new?(entry)
    entry.published > @feed.last_fetched
  end
end