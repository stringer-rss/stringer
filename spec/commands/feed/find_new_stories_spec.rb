# frozen_string_literal: true

RSpec.describe Feed::FindNewStories do
  def create_entry(**options)
    entry = {
      published: nil,
      title: "story1",
      url: "www.story1.com",
      content: "",
      id: "www.story1.com",
      **options
    }
    double(entry)
  end

  def create_raw_feed(feed, entries: [])
    xml = GenerateXml.call(feed, entries)
    Feedjira.parse(xml)
  end

  context "the feed contains no new stories" do
    it "finds zero new stories" do
      feed = create(:feed)
      create(:story, entry_id: "www.story1.com", feed_id: feed.id)
      raw_feed = create_raw_feed(feed, entries: [create_entry])
      result = described_class.call(raw_feed, feed.id)

      expect(result).to be_empty
    end
  end

  context "the feed contains new stories" do
    it "returns stories that are not found in the database" do
      feed = create(:feed)
      create(:story, entry_id: "www.story1.com", feed_id: feed.id)
      entry = create_entry(published: Time.zone.now, url: "www.story2.com")
      raw_feed = create_raw_feed(feed, entries: [entry])

      expect(described_class.call(raw_feed, feed.id)).to eq(raw_feed.entries)
    end
  end

  it "finds new stories listed after an existing story" do
    story = create(:story, entry_id: "www.pinned.com")
    entries = [story.entry_id, "www.new.com"].map { |url| create_entry(url:) }
    raw_feed = create_raw_feed(story.feed, entries:)

    expect(described_class.call(raw_feed, story.feed_id))
      .to eq([raw_feed.entries.last])
  end

  it "ignores stories older than 3 days" do
    new_entry = create_entry(title: "new", published: 2.days.ago)
    old_entry = create_entry(title: "old", published: 4.days.ago)
    raw_feed = create_raw_feed(create(:feed), entries: [old_entry, new_entry])

    expect(described_class.call(raw_feed, 1))
      .to eq(raw_feed.entries.filter { |entry| entry.title == "new" })
  end
end
