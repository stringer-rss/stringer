require "spec_helper"
require "support/active_record"

app_require "repositories/feed_repository"

describe FeedRepository do
  describe ".update_last_fetched" do
    let(:timestamp) { Time.now }

    it "saves the last_fetched timestamp" do
      feed = Feed.new

      result = FeedRepository.update_last_fetched(feed, timestamp)

      feed.last_fetched.should eq timestamp
    end

    let(:weird_timestamp) { Time.parse("Mon, 01 Jan 0001 00:00:00 +0100") }

    it "rejects weird timestamps" do
      feed = Feed.new(last_fetched: timestamp)

      result = FeedRepository.update_last_fetched(feed, weird_timestamp)

      feed.last_fetched.should eq timestamp
    end

    it "doesn't update if timestamp is nil (feed does not report last modified)" do
      feed = Feed.new(last_fetched: timestamp)

      result = FeedRepository.update_last_fetched(feed, nil)

      feed.last_fetched.should eq timestamp
    end

    it "doesn't update if timestamp is older than the current value" do
      feed = Feed.new(last_fetched: timestamp)
      one_week_ago = timestamp - 1.week

      result = FeedRepository.update_last_fetched(feed, one_week_ago)

      feed.last_fetched.should eq timestamp
    end
  end

  describe "fetch" do
    let(:feed) { Feed.new(id: 1) }

    it "finds by id" do
      Feed.should_receive(:find).with(feed.id).and_return(feed)
      FeedRepository.fetch(feed.id)
    end

    it "returns found feed" do
      Feed.stub(:find).with(feed.id).and_return(feed)

      result = FeedRepository.fetch(feed.id)

      result.should eq feed
    end
  end
end