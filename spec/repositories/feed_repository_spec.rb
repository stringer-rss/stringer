# frozen_string_literal: true

require "spec_helper"
require "support/active_record"

app_require "repositories/feed_repository"

describe FeedRepository do
  describe ".fetch" do
    let(:feed) { Feed.new(id: 1) }

    it "finds by id" do
      expect(Feed).to receive(:find).with(feed.id).and_return(feed)
      described_class.fetch(feed.id)
    end

    it "returns found feed" do
      allow(Feed).to receive(:find).with(feed.id).and_return(feed)

      result = described_class.fetch(feed.id)

      expect(result).to eq(feed)
    end
  end

  describe ".fetch_by_ids" do
    it "finds all feeds by id" do
      feeds = create_pair(:feed)

      expect(described_class.fetch_by_ids(feeds.map(&:id)))
        .to match_array(feeds)
    end

    it "does not find other feeds" do
      feed1, = create_pair(:feed)

      expect(described_class.fetch_by_ids(feed1.id)).to eq([feed1])
    end
  end

  describe ".update_feed" do
    it "saves the name and url" do
      feed = Feed.new

      described_class.update_feed(feed, "Test Feed", "example.com/feed")

      expect(feed.name).to eq("Test Feed")
      expect(feed.url).to eq("example.com/feed")
    end
  end

  describe ".update_last_fetched" do
    let(:timestamp) { Time.now }

    it "saves the last_fetched timestamp" do
      feed = Feed.new

      described_class.update_last_fetched(feed, timestamp)

      expect(feed.last_fetched).to eq(timestamp)
    end

    it "rejects weird timestamps" do
      weird_timestamp = Time.parse("Mon, 01 Jan 0001 00:00:00 +0100")
      feed = Feed.new(last_fetched: timestamp)

      described_class.update_last_fetched(feed, weird_timestamp)

      expect(feed.last_fetched).to eq(timestamp)
    end

    it "doesn't update if timestamp is nil" do
      feed = Feed.new(last_fetched: timestamp)

      described_class.update_last_fetched(feed, nil)

      expect(feed.last_fetched).to eq(timestamp)
    end

    it "doesn't update if timestamp is older than the current value" do
      feed = Feed.new(last_fetched: timestamp)
      one_week_ago = timestamp - 1.week

      described_class.update_last_fetched(feed, one_week_ago)

      expect(feed.last_fetched).to eq(timestamp)
    end
  end

  describe ".delete" do
    it "deletes the feed by id" do
      feed = create(:feed)

      described_class.delete(feed.id)

      expect(Feed.unscoped.find_by(id: feed.id)).to be_nil
    end

    it "does not delete other feeds" do
      feed1, feed2 = create_pair(:feed)

      described_class.delete(feed1.id)

      expect(Feed.unscoped.find_by(id: feed2.id)).to eq(feed2)
    end
  end

  describe ".list" do
    it "returns all feeds ordered by name, case insensitive" do
      feed1 = create(:feed, name: "foo")
      feed2 = create(:feed, name: "Fabulous")
      feed3 = create(:feed, name: "Zooby")
      feed4 = create(:feed, name: "zabby")

      expect(described_class.list).to eq([feed2, feed1, feed4, feed3])
    end
  end

  describe ".in_group" do
    it "returns feeds that are in a group" do
      feed1 = create(:feed, group_id: 5)
      feed2 = create(:feed, group_id: 6)

      expect(described_class.in_group).to match_array([feed1, feed2])
    end

    it "does not return feeds that are not in a group" do
      create_pair(:feed)

      expect(described_class.in_group).to be_empty
    end
  end
end
