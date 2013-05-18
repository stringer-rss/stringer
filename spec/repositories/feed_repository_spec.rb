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
  end
end