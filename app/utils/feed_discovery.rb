# frozen_string_literal: true

module FeedDiscovery
  class << self
    def call(url)
      get_feed_for_url(url) do
        urls = discover_feeds(url)
        return false if urls.empty?

        get_feed_for_url(urls.first) { return false }
      end
    end

    private

    def discover_feeds(url)
      SafeFetch.guard(url) { Feedbag.find(url) }
    rescue SafeFetch::UnsafeUrl
      []
    end

    def get_feed_for_url(url)
      response = SafeFetch.body(url)
      feed = Feedjira.parse(response)
      feed.feed_url ||= url
      feed
    rescue StandardError
      yield
    end
  end
end
