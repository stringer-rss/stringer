# frozen_string_literal: true

module AddNewFeed
  def self.call(url, repo = Feed, user:)
    result = FeedDiscovery.call(url)
    return false unless result

    name = ContentSanitizer.call(result.title.presence || result.feed_url)

    repo.create(name:, user:, url: result.feed_url, last_fetched: 1.day.ago)
  end
end
