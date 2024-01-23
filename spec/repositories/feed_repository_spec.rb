# frozen_string_literal: true

RSpec.describe FeedRepository do
  describe ".fetch" do
    it "finds and returns found feed" do
      feed = create(:feed)

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
      feed = build(:feed)

      described_class.update_feed(feed, "Test Feed", "example.com/feed")

      expect(feed.name).to eq("Test Feed")
      expect(feed.url).to eq("example.com/feed")
    end
  end

  describe ".update_last_fetched" do
    it "saves the last_fetched timestamp" do
      timestamp = Time.zone.now.round
      feed = build(:feed)

      described_class.update_last_fetched(feed, timestamp)

      expect(feed.last_fetched).to eq(timestamp)
    end

    it "rejects weird timestamps" do
      timestamp = Time.zone.now.round
      weird_timestamp = Time.parse("Mon, 01 Jan 0001 00:00:00 +0100")
      feed = Feed.new(last_fetched: timestamp)

      described_class.update_last_fetched(feed, weird_timestamp)

      expect(feed.last_fetched).to eq(timestamp)
    end

    it "doesn't update if timestamp is nil" do
      timestamp = Time.zone.now.round
      feed = Feed.new(last_fetched: timestamp)

      described_class.update_last_fetched(feed, nil)

      expect(feed.last_fetched).to eq(timestamp)
    end

    it "doesn't update if timestamp is older than the current value" do
      timestamp = Time.zone.now.round
      feed = Feed.new(last_fetched: timestamp)
      one_week_ago = timestamp - 1.week

      described_class.update_last_fetched(feed, one_week_ago)

      expect(feed.last_fetched).to eq(timestamp)
    end
  end

  describe ".delete" do
    it "deletes the feed by id" do
      feed = create(:feed)

      expect { described_class.delete(feed.id) }.to delete_record(feed)
    end

    it "does not delete other feeds" do
      feed1, feed2 = create_pair(:feed)

      expect { described_class.delete(feed1.id) }.not_to delete_record(feed2)
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

      expect(described_class.in_group).to contain_exactly(feed1, feed2)
    end

    it "does not return feeds that are not in a group" do
      create_pair(:feed)

      expect(described_class.in_group).to be_empty
    end
  end
end
