# frozen_string_literal: true

RSpec.describe RefreshFromFeed do
  def create_entry(**options)
    entry = {
      guid: "entry-guid",
      published: Time.zone.now,
      title: "Updated title",
      url: "https://example.com/updated",
      content: "Updated content",
      enclosure_url: "https://example.com/updated.mp3",
      **options
    }
    double(entry)
  end

  def stub_raw_feed(feed, entries: [])
    xml = GenerateXml.call(feed, entries)
    stub_request(:get, feed.url).to_return(status: 200, body: xml)
  end

  def stub_invalid_feed(feed)
    stub_request(:get, feed.url).to_return(status: 200, body: "not a feed")
  end

  def create_refreshable_story(**)
    story = create(:story, entry_id: "entry-guid", **)
    stub_raw_feed(story.feed, entries: [create_entry])
    story
  end

  context "when the entry is still in the feed" do
    it "updates the enclosure url" do
      story =
        create_refreshable_story(enclosure_url: "https://example.com/dead.mp3")

      expect { described_class.call(story) }
        .to change_record(story, :enclosure_url)
        .to("https://example.com/updated.mp3")
    end

    it "updates the title and body" do
      story = create_refreshable_story(title: "Old title")

      described_class.call(story)

      expect(story.reload)
        .to have_attributes(title: "Updated title", body: "Updated content")
    end

    it "updates the permalink" do
      story = create_refreshable_story

      described_class.call(story)

      expect(story.reload.permalink).to eq("https://example.com/updated")
    end

    it "returns true" do
      story = create_refreshable_story

      expect(described_class.call(story)).to be(true)
    end
  end

  context "when the entry is no longer in the feed" do
    it "returns false" do
      story = create_refreshable_story(entry_id: "gone-guid")

      expect(described_class.call(story)).to be(false)
    end

    it "does not change the story" do
      story =
        create_refreshable_story(entry_id: "gone-guid", title: "Old title")

      described_class.call(story)

      expect(story.reload.title).to eq("Old title")
    end
  end

  context "when the feed cannot be fetched or parsed" do
    it "returns false" do
      story = create(:story)
      stub_invalid_feed(story.feed)

      expect(described_class.call(story)).to be(false)
    end

    it "logs an error" do
      story = create(:story)
      stub_invalid_feed(story.feed)

      expect { described_class.call(story) }
        .to invoke(:error).on(Rails.logger).with(/refreshing story/)
    end
  end
end
