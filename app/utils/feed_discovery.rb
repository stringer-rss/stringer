require "feedbag"
require "feedzirra"

class FeedDiscovery
  def discover(url, finder = Feedbag, parser = Feedzirra::Feed)
    feed = get_feed_for_url(url, finder, parser) do
      urls = finder.find(url)
      return false if urls.empty?

      get_feed_for_url(urls.first, finder, parser) do
        return false
      end
    end

    feed.feed_url ||= url
    feed
  end

  def get_feed_for_url(url, finder, parser)
    feed = parser.fetch_and_parse(url)
  rescue Exception
    yield if block_given?
  end
end
