require "feedbag"
require "feedjira"
require "httparty"

class FeedDiscovery
  def discover(url, finder = Feedbag, parser = Feedjira, client = HTTParty)
    get_feed_for_url(url, parser, client) do
      urls = finder.find(url)
      return false if urls.empty?

      get_feed_for_url(urls.first, parser, client) do
        return false
      end
    end
  end

  def get_feed_for_url(url, parser, client)
    response = client.get(url).to_s
    feed = parser.parse(response)
    feed.feed_url ||= url
    feed
  rescue StandardError
    yield if block_given?
  end
end
