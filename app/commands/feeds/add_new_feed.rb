require_relative "../../models/feed"
require_relative "../../utils/content_sanitizer"
require_relative "../../utils/feed_discovery"

class AddNewFeed
  ONE_DAY = 24 * 60 * 60

  def self.add(url, discoverer = FeedDiscovery.new, repo = Feed)
    result = discoverer.discover(url)
    return false unless result

    name = ContentSanitizer.sanitize(result.title.presence || result.feed_url)

    repo.create(name:, url: result.feed_url, last_fetched: Time.now - ONE_DAY)
  end
end
