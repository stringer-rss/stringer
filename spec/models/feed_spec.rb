# frozen_string_literal: true

require "spec_helper"
require "support/active_record"

app_require "models/feed"

describe "Feed" do
  describe "#status_bubble" do
    it "returns 'yellow' when status == 'red' and there are stories" do
      feed = Feed.new(status: :red, stories: [Story.new])

      expect(feed.status_bubble).to eq("yellow")
    end

    it "returns 'red' if status is 'red' and there are no stories" do
      feed = Feed.new(status: :red)

      expect(feed.status_bubble).to eq("red")
    end

    it "returns nil when no status is set" do
      feed = Feed.new

      expect(feed.status_bubble).to be_nil
    end

    it "returns :green when status is :green" do
      feed = Feed.new(status: :green)

      expect(feed.status_bubble).to eq("green")
    end
  end

  describe "#unread_stories" do
    it "returns stories where is_read is false" do
      feed = Feed.create!
      story = feed.stories.create!(is_read: false)

      expect(feed.unread_stories).to eq([story])
    end

    it "does not return stories where is_read is true" do
      feed = Feed.create!
      feed.stories.create!(is_read: true)

      expect(feed.unread_stories).to be_empty
    end

    it "does not return stories where is_read is nil" do
      feed = Feed.create!
      feed.stories.create!

      expect(feed.unread_stories).to be_empty
    end
  end

  describe "#as_fever_json" do
    it "returns a hash of the feed in fever format" do
      last_fetched = 1.day.ago
      feed = Feed.new(
        id: 52,
        name: "chicken feed",
        url: "wat url",
        last_fetched:
      )

      expect(feed.as_fever_json).to eq(
        id: 52,
        favicon_id: 0,
        title: "chicken feed",
        url: "wat url",
        site_url: "wat url",
        is_spark: 0,
        last_updated_on_time: last_fetched.to_i
      )
    end
  end
end
