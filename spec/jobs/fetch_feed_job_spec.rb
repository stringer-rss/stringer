# frozen_string_literal: true

require "spec_helper"

app_require "jobs/fetch_feed_job"

RSpec.describe FetchFeedJob do
  it "fetches feeds" do
    job = described_class.new(123)
    feed = Feed.new(id: 123, url: "http://example.com/feed")
    expect(FeedRepository).to receive(:fetch).with(123).and_return(feed)
    expect(FetchFeed).to receive(:new).with(feed).and_return(double(fetch: nil))
    job.perform
  end
end
