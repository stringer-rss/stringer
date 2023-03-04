# frozen_string_literal: true

RSpec.describe FetchFeedJob do
  it "fetches feeds" do
    job = described_class.new(123)
    feed = Feed.new(id: 123, url: "http://example.com/feed")
    expect(FeedRepository).to receive(:fetch).with(123).and_return(feed)
    expect(FetchFeed).to receive(:call).with(feed)
    job.perform
  end
end
