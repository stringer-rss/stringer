# frozen_string_literal: true

module AddNewFeed
  def self.call(url, discoverer = FeedDiscovery, repo = Feed, user:)
    result = discoverer.call(url)
    return false unless result

    name = ContentSanitizer.call(result.title.presence || result.feed_url)

    repo.create(name:, user:, url: result.feed_url, last_fetched: 1.day.ago)
  end
end
