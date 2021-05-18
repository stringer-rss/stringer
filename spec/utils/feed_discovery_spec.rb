require "spec_helper"

app_require "utils/feed_discovery"

describe FeedDiscovery do
  let(:finder) { double }
  let(:client) { class_double(HTTParty) }
  let(:parser) { class_double(Feedjira) }
  let(:feed) { double(feed_url: url) }
  let(:url) { "http://example.com" }

  let(:invalid_discovered_url) { "http://not-a-valid-feed.com" }
  let(:valid_discovered_url) { "http://a-valid-feed.com" }

  describe "#discover" do
    it "returns false if url is not a feed and feed url cannot be discovered" do
      expect(client).to receive(:get).with(url)
      expect(parser).to receive(:parse).and_raise(StandardError)
      expect(finder).to receive(:find).and_return([])

      result = FeedDiscovery.new.discover(url, finder, parser, client)

      expect(result).to eq(false)
    end

    it "returns a feed if the url provided is parsable" do
      expect(client).to receive(:get).with(url)
      expect(parser).to receive(:parse).and_return(feed)

      result = FeedDiscovery.new.discover(url, finder, parser, client)

      expect(result).to eq feed
    end

    it "returns false if the discovered feed is not parsable" do
      expect(client).to receive(:get).with(url)
      expect(parser).to receive(:parse).and_raise(StandardError)

      expect(finder).to receive(:find).and_return([invalid_discovered_url])

      expect(client).to receive(:get).with(invalid_discovered_url)
      expect(parser).to receive(:parse).and_raise(StandardError)

      result = FeedDiscovery.new.discover(url, finder, parser, client)

      expect(result).to eq(false)
    end

    it "returns the feed if the discovered feed is parsable" do
      expect(client).to receive(:get).with(url)
      expect(parser).to receive(:parse).and_raise(StandardError)

      expect(finder).to receive(:find).and_return([valid_discovered_url])

      expect(client).to receive(:get).with(valid_discovered_url)
      expect(parser).to receive(:parse).and_return(feed)

      result = FeedDiscovery.new.discover(url, finder, parser, client)

      expect(result).to eq feed
    end
  end
end
