require "spec_helper"
require "support/active_record"

app_require "repositories/feed_repository"

describe FeedRepository do
  describe ".fetch" do
    let(:feed) { Feed.new(id: 1) }

    it "finds by id" do
      expect(Feed).to receive(:find).with(feed.id).and_return(feed)
      FeedRepository.fetch(feed.id)
    end

    it "returns found feed" do
      allow(Feed).to receive(:find).with(feed.id).and_return(feed)

      result = FeedRepository.fetch(feed.id)

      expect(result).to eq feed
    end
  end

  describe ".fetch_by_ids" do
    it "finds all feeds by id" do
      feeds = [create_feed, create_feed]

      expect(FeedRepository.fetch_by_ids(feeds.map(&:id))).to match_array(feeds)
    end

    it "does not find other feeds" do
      feed1 = create_feed
      create_feed

      expect(FeedRepository.fetch_by_ids(feed1.id)).to eq([feed1])
    end
  end

  describe ".update_feed" do
    it "saves the name and url" do
      feed = Feed.new

      FeedRepository.update_feed(feed, "Test Feed", "example.com/feed")

      expect(feed.name).to eq "Test Feed"
      expect(feed.url).to eq "example.com/feed"
    end
  end

  describe ".update_last_fetched" do
    let(:timestamp) { Time.now }

    it "saves the last_fetched timestamp" do
      feed = Feed.new

      FeedRepository.update_last_fetched(feed, timestamp)

      expect(feed.last_fetched).to eq timestamp
    end

    let(:weird_timestamp) { Time.parse("Mon, 01 Jan 0001 00:00:00 +0100") }

    it "rejects weird timestamps" do
      feed = Feed.new(last_fetched: timestamp)

      FeedRepository.update_last_fetched(feed, weird_timestamp)

      expect(feed.last_fetched).to eq timestamp
    end

    it "doesn't update if timestamp is nil (feed does not report last modified)" do
      feed = Feed.new(last_fetched: timestamp)

      FeedRepository.update_last_fetched(feed, nil)

      expect(feed.last_fetched).to eq timestamp
    end

    it "doesn't update if timestamp is older than the current value" do
      feed = Feed.new(last_fetched: timestamp)
      one_week_ago = timestamp - 1.week

      FeedRepository.update_last_fetched(feed, one_week_ago)

      expect(feed.last_fetched).to eq timestamp
    end
  end

  describe ".delete" do
    it "deletes the feed by id" do
      feed = create_feed

      FeedRepository.delete(feed.id)

      expect(Feed.unscoped.find_by(id: feed.id)).to be_nil
    end

    it "does not delete other feeds" do
      feed1 = create_feed
      feed2 = create_feed

      FeedRepository.delete(feed1.id)

      expect(Feed.unscoped.find_by(id: feed2.id)).to eq(feed2)
    end
  end

  describe ".list" do
    it "returns all feeds ordered by name, case insensitive" do
      feed1 = create_feed(name: "foo")
      feed2 = create_feed(name: "Fabulous")
      feed3 = create_feed(name: "Zooby")
      feed4 = create_feed(name: "zabby")

      expect(FeedRepository.list).to eq([feed2, feed1, feed4, feed3])
    end
  end

  describe ".in_group" do
    it "returns feeds that are in a group" do
      feed1 = create_feed(group_id: 5)
      feed2 = create_feed(group_id: 6)

      expect(FeedRepository.in_group).to match_array([feed1, feed2])
    end

    it "does not return feeds that are not in a group" do
      create_feed
      create_feed

      expect(FeedRepository.in_group).to be_empty
    end
  end
end
