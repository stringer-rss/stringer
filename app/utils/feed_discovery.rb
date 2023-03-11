# frozen_string_literal: true

module FeedDiscovery
  class << self
    def call(url, client = HTTParty)
      get_feed_for_url(url, client) do
        urls = Feedbag.find(url)
        return false if urls.empty?

        get_feed_for_url(urls.first, client) { return false }
      end
    end

    private

    def get_feed_for_url(url, client)
      response = client.get(url).to_s
      feed = Feedjira.parse(response)
      feed.feed_url ||= url
      feed
    rescue StandardError
      yield
    end
  end
end
