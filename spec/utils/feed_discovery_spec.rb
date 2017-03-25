require "spec_helper"

app_require "utils/feed_discovery"

describe FeedDiscovery do
  let(:finder) { double }
  let(:parser) { double }
  let(:feed) { double(feed_url: url) }
  let(:url) { "http://example.com" }

  let(:invalid_discovered_url) { "http://not-a-valid-feed.com" }
  let(:valid_discovered_url) { "http://a-valid-feed.com" }

  describe "#discover" do
    it "returns false if url is not a feed and feed url cannot be discovered" do
      expect(parser).to receive(:fetch_and_parse).with(url).and_raise(StandardError)
      expect(finder).to receive(:find).and_return([])

      result = FeedDiscovery.new.discover(url, finder, parser)

      expect(result).to eq(false)
    end

    it "returns a feed if the url provided is parsable" do
      expect(parser).to receive(:fetch_and_parse).with(url).and_return(feed)

      result = FeedDiscovery.new.discover(url, finder, parser)

      expect(result).to eq feed
    end

    it "returns false if the discovered feed is not parsable" do
      expect(parser).to receive(:fetch_and_parse).with(url).and_raise(StandardError)
      expect(finder).to receive(:find).and_return([invalid_discovered_url])
      expect(parser).to receive(:fetch_and_parse).with(invalid_discovered_url).and_raise(StandardError)

      result = FeedDiscovery.new.discover(url, finder, parser)

      expect(result).to eq(false)
    end

    it "returns the feed if the discovered feed is parsable" do
      expect(parser).to receive(:fetch_and_parse).with(url).and_raise(StandardError)
      expect(finder).to receive(:find).and_return([valid_discovered_url])
      expect(parser).to receive(:fetch_and_parse).with(valid_discovered_url).and_return(feed)

      result = FeedDiscovery.new.discover(url, finder, parser)

      expect(result).to eq feed
    end
  end
end
