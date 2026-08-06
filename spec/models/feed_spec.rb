# frozen_string_literal: true

RSpec.describe "Feed" do
  describe ".with_unread_stories_counts" do
    it "returns feeds with unread stories counts" do
      create(:story)

      feed = Feed.with_unread_stories_counts.first

      expect(feed.unread_stories_count).to eq(1)
    end

    it "includes feeds with no unread stories" do
      create(:story, :read)

      feed = Feed.with_unread_stories_counts.first

      expect(feed.unread_stories_count).to eq(0)
    end
  end

  describe "#unread_stories" do
    it "returns stories where is_read is false" do
      feed = create(:feed)
      story = create(:story, feed:)

      expect(feed.unread_stories).to eq([story])
    end

    it "does not return stories where is_read is true" do
      feed = create(:feed)
      create(:story, :read, feed:)

      expect(feed.unread_stories).to be_empty
    end
  end

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

    it "replaces a null title with an empty string" do
      last_fetched = 1.day.ago
      feed = Feed.new(id: 52, name: nil, url: "wat url", last_fetched:)

      expect(feed.as_fever_json).to eq(
        id: 52,
        favicon_id: 0,
        title: "",
        url: "wat url",
        site_url: "wat url",
        is_spark: 0,
        last_updated_on_time: last_fetched.to_i
      )
    end
  end

  describe "url scheme validation" do
    it "allows an http url" do
      expect(build(:feed, url: "http://example.com/feed")).to be_valid
    end

    it "allows an https url" do
      expect(build(:feed, url: "https://example.com/feed")).to be_valid
    end

    it "rejects a javascript url" do
      expect(build(:feed, url: "javascript:alert(1)")).not_to be_valid
    end

    it "explains why a javascript url was rejected" do
      feed = build(:feed, url: "javascript:alert(1)")
      feed.valid?

      expect(feed.errors[:url]).to eq(["must be an http or https address"])
    end

    it "rejects a url with no scheme, which we could never fetch" do
      expect(build(:feed, url: "example.com/feed")).not_to be_valid
    end

    it "leaves a blank url to the presence validation alone" do
      feed = build(:feed, url: "")
      feed.valid?

      expect(feed.errors[:url]).to eq(["can't be blank"])
    end

    it "still lets rows stored before the validation record their status" do
      feed = build(:feed, url: "example.com/legacy")
      feed.save!(validate: false)

      expect(feed.update(status: :red)).to be(true)
    end
  end
end
