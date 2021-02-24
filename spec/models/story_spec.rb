require "spec_helper"
require "support/active_record"

app_require "models/story"

describe "Story" do
  let(:story) do
    Story.new(
      title: Faker::Lorem.sentence(word_count: 50),
      body: Faker::Lorem.sentence(word_count: 50)
    )
  end

  describe "#headline" do
    it "truncates to 50 chars" do
      expect(story.headline.size).to eq(50)
    end

    it "uses a fallback string if story has no title" do
      story.title = nil
      expect(story.headline).to eq(Story::UNTITLED)
    end

    it "strips html out" do
      story.title = "<b>Super cool</b> stuff"
      expect(story.headline).to eq "Super cool stuff"
    end
  end

  describe "#lead" do
    it "truncates to 100 chars" do
      expect(story.lead.size).to eq(100)
    end

    it "strips html out" do
      story.body = "<a href='http://github.com'>Yo</a> dawg"
      expect(story.lead).to eq "Yo dawg"
    end
  end

  describe "#source" do
    let(:feed) { Feed.new(name: "Superfeed") }
    before { story.feed = feed }

    it "returns the feeds name" do
      expect(story.source).to eq(feed.name)
    end
  end

  describe "#pretty_date" do
    it "returns a formatted published date" do
      published_at = Time.now
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
      feed = create_feed(name: "my feed")
      published_at = 1.day.ago
      created_at = 1.hour.ago
      updated_at = 1.minute.ago
      story = create_story(
        body: "story body",
        created_at: created_at,
        entry_id: 5,
        feed: feed,
        is_read: true,
        is_starred: false,
        keep_unread: true,
        permalink: "www.exampoo.com/perma",
        published: published_at,
        title: "the story title",
        updated_at: updated_at
      )

      expect(story.as_json).to eq({
        body: "story body",
        created_at: created_at,
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
        published: published_at.utc,
        source: "my feed",
        title: "the story title",
        updated_at: updated_at
      }.stringify_keys)
    end
  end

  describe "#as_fever_json" do
    it "returns a hash of the story in fever format" do
      feed = create_feed(name: "my feed")
      published_at = 1.day.ago
      story = create_story(
        feed: feed,
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
  end
end
