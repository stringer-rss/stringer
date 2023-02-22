# frozen_string_literal: true

require_relative "../../models/feed"
require_relative "../../utils/content_sanitizer"
require_relative "../../utils/feed_discovery"

module AddNewFeed
  def self.call(url, discoverer = FeedDiscovery.new, repo = Feed, user:)
    result = discoverer.discover(url)
    return false unless result

    name = ContentSanitizer.sanitize(result.title.presence || result.feed_url)

    repo.create(name:, user:, url: result.feed_url, last_fetched: 1.day.ago)
  end
end
