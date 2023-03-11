# frozen_string_literal: true

module FeedDiscovery
  class << self
    def call(url)
      get_feed_for_url(url) do
        urls = Feedbag.find(url)
        return false if urls.empty?

        get_feed_for_url(urls.first) { return false }
      end
    end

    private

    def get_feed_for_url(url)
      response = HTTParty.get(url).to_s
      feed = Feedjira.parse(response)
      feed.feed_url ||= url
      feed
    rescue StandardError
      yield
    end
  end
end
