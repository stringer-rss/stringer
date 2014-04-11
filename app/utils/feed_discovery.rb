require "feedbag"
require "feedjira"

class FeedDiscovery
  def discover(url, finder = Feedbag, parser = Feedjira::Feed)
    get_feed_for_url(url, finder, parser) do
      urls = finder.find(url)
      return false if urls.empty?

      get_feed_for_url(urls.first, finder, parser) do
        return false
      end
    end
  end

  def get_feed_for_url(url, finder, parser)
    feed = parser.fetch_and_parse(url, user_agent: "Stringer")
    feed.feed_url ||= url
    feed
  rescue Exception
    yield if block_given?
  end
end
