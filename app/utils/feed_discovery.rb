require "feedbag"
require "feedzirra"

class FeedDiscovery
  def discover(url, finder = Feedbag, parser = Feedzirra::Feed)
    begin
      feed = parser.fetch_and_parse(url)
      feed.feed_url ||= url
      return feed
    rescue Exception => e
      urls = finder.find(url)
      return false if urls.empty?
    end

    begin
      feed = parser.fetch_and_parse(urls.first)
      feed.feed_url ||= urls.first
      return feed
    rescue Exception => e
      return false
    end
  end
end