# frozen_string_literal: true

module FeedDiscovery
  class << self
    def call(url, finder = Feedbag, parser = Feedjira, client = HTTParty)
      get_feed_for_url(url, parser, client) do
        urls = finder.find(url)
        return false if urls.empty?

        get_feed_for_url(urls.first, parser, client) { return false }
      end
    end

    private

    def get_feed_for_url(url, parser, client)
      response = client.get(url).to_s
      feed = parser.parse(response)
      feed.feed_url ||= url
      feed
    rescue StandardError
      yield
    end
  end
end
