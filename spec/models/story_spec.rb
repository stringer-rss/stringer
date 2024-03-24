# frozen_string_literal: true

RSpec.describe "Story" do
  describe ".unread" do
    it "returns stories where is_read is false" do
      story = create(:story)

      expect(Story.unread).to eq([story])
    end

    it "does not return stories where is_read is true" do
      create(:story, :read)

      expect(Story.unread).to be_empty
    end
  end

  describe "#headline" do
    it "truncates to 50 chars" do
      story = Story.new(title: "a" * 100)

      expect(story.headline.size).to eq(50)
    end

    it "uses a fallback string if story has no title" do
      story = build_stubbed(:story)
      story.title = nil
      expect(story.headline).to eq(Story::UNTITLED)
    end

    it "strips html out" do
      story = build_stubbed(:story)
      story.title = "<b>Super cool</b> stuff"
      expect(story.headline).to eq("Super cool stuff")
    end
  end

  describe "#lead" do
    it "truncates to 100 chars" do
      story = Story.new(body: "a" * 1000)

      expect(story.lead.size).to eq(100)
    end

    it "strips html out" do
      story = build_stubbed(:story)
      story.body = "<a href='http://github.com'>Yo</a> dawg"
      expect(story.lead).to eq("Yo dawg")
    end
  end

  describe "#source" do
    it "returns the feeds name" do
      story = build_stubbed(:story)
      feed = Feed.new(name: "Superfeed")
      story.feed = feed

      expect(story.source).to eq(feed.name)
    end
  end

  describe "#pretty_date" do
    it "returns a formatted published date" do
      published_at = Time.zone.now
      story = Story.new(published: published_at)

      expect(story.pretty_date).to eq(I18n.l(published_at))
    end

    it "raises an error when published is nil" do
      story = Story.new

      expect { story.pretty_date }.to raise_error(ArgumentError)
    end
  end

  describe "#as_json" do
    it "returns a hash of the story" do
      feed = create(:feed, name: "my feed")
      published_at = 1.day.ago
      created_at = 1.hour.ago
      updated_at = 1.minute.ago
      story = create(
        :story,
        body: "story body",
        created_at:,
        entry_id: 5,
        feed:,
        is_read: true,
        is_starred: false,
        keep_unread: true,
        permalink: "www.exampoo.com/perma",
        published: published_at,
        title: "the story title",
        updated_at:
      )

      expect(story.as_json).to eq(
        {
          body: "story body",
          created_at: created_at.utc.as_json,
          enclosure_url: nil,
          entry_id: "5",
          feed_id: feed.id,
          headline: "the story title",
          id: story.id,
          is_read: true,
          is_starred: false,
          keep_unread: true,
          lead: "story body",
          permalink: "www.exampoo.com/perma",
          pretty_date: I18n.l(published_at.utc),
          published: published_at.utc.as_json,
          source: "my feed",
          title: "the story title",
          updated_at: updated_at.utc.as_json
        }.stringify_keys
      )
    end
  end

  describe "#as_fever_json" do
    it "returns a hash of the story in fever format" do
      feed = create(:feed, name: "my feed")
      published_at = 1.day.ago
      story = create(
        :story,
        feed:,
        title: "the story title",
        body: "story body",
        permalink: "www.exampoo.com/perma",
        published: published_at,
        is_read: true
      )

      expect(story.as_fever_json).to eq(
        id: story.id,
        feed_id: feed.id,
        title: "the story title",
        author: "my feed",
        html: "story body",
        url: "www.exampoo.com/perma",
        is_saved: 0,
        is_read: 1,
        created_on_time: published_at.to_i
      )
    end

    it "returns is_read as 0 if story is unread" do
      story = create(:story, is_read: false)
      expect(story.as_fever_json[:is_read]).to eq(0)
    end

    it "returns is_saved as 1 if story is starred" do
      story = create(:story, is_starred: true)
      expect(story.as_fever_json[:is_saved]).to eq(1)
    end
  end
end
