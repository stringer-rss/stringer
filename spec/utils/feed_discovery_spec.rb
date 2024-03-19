# frozen_string_literal: true

RSpec.describe FeedDiscovery do
  url = "http://example.com"
  invalid_discovered_url = "http://not-a-valid-feed.com"
  valid_discovered_url = "http://a-valid-feed.com"

  it "returns false if url is not a feed and feed url cannot be discovered" do
    expect(HTTParty).to receive(:get).with(url)
    expect(Feedjira).to receive(:parse).and_raise(StandardError)
    expect(Feedbag).to receive(:find).and_return([])

    result = described_class.call(url)

    expect(result).to be(false)
  end

  it "returns a feed if the url provided is parsable" do
    feed = double(feed_url: url)
    expect(HTTParty).to receive(:get).with(url)
    expect(Feedjira).to receive(:parse).and_return(feed)

    result = described_class.call(url)

    expect(result).to eq(feed)
  end

  it "returns false if the discovered feed is not parsable" do
    expect(HTTParty).to receive(:get).with(url)
    expect(Feedjira).to receive(:parse).and_raise(StandardError)

    expect(Feedbag).to receive(:find).and_return([invalid_discovered_url])

    expect(HTTParty).to receive(:get).with(invalid_discovered_url)
    expect(Feedjira).to receive(:parse).and_raise(StandardError)

    result = described_class.call(url)

    expect(result).to be(false)
  end

  it "returns the feed if the discovered feed is parsable" do
    feed = double(feed_url: url)
    expect(HTTParty).to receive(:get).with(url)
    expect(Feedjira).to receive(:parse).and_raise(StandardError)

    expect(Feedbag).to receive(:find).and_return([valid_discovered_url])

    expect(HTTParty).to receive(:get).with(valid_discovered_url)
    expect(Feedjira).to receive(:parse).and_return(feed)

    result = described_class.call(url)

    expect(result).to eq(feed)
  end
end
