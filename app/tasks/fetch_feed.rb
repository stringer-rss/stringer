# frozen_string_literal: true

require "feedjira"
require "httparty"

require_relative "../repositories/story_repository"
require_relative "../repositories/feed_repository"
require_relative "../commands/feeds/find_new_stories"

module FetchFeed
  class << self
    def call(feed)
      raw_feed = fetch_raw_feed(feed)

      new_entries_from(feed, raw_feed).each do |entry|
        StoryRepository.add(entry, feed)
      end

      FeedRepository.update_last_fetched(feed, raw_feed.last_modified)

      FeedRepository.set_status(:green, feed)
    rescue StandardError => e
      FeedRepository.set_status(:red, feed)

      Rails.logger.error("Something went wrong when parsing #{feed.url}: #{e}")
    end

    private

    def fetch_raw_feed(feed)
      response = HTTParty.get(feed.url).to_s
      Feedjira.parse(response)
    end

    def new_entries_from(feed, raw_feed)
      FindNewStories.call(
        raw_feed,
        feed.id,
        feed.last_fetched,
        latest_entry_id(feed)
      )
    end

    def latest_entry_id(feed)
      return feed.stories.first.entry_id unless feed.stories.empty?
    end
  end
end
