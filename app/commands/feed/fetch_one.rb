# frozen_string_literal: true

module Feed::FetchOne
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
      response = SafeFetch.body(feed.url)
      Feedjira.parse(response)
    end

    def new_entries_from(feed, raw_feed)
      Feed::FindNewStories.call(raw_feed, feed.id)
    end
  end
end
