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
      response = HTTParty.get(feed.url).to_s
      Feedjira.parse(response)
    end

    def new_entries_from(feed, raw_feed)
      Feed::FindNewStories.call(raw_feed, feed.id, latest_entry_id(feed))
    end

    def latest_entry_id(feed)
      feed.stories.first.entry_id unless feed.stories.empty?
    end
  end
end
