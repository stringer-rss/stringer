# frozen_string_literal: true

RSpec.describe Feed::FetchOne do
  def create_entry(opts: {})
    entry = {
      comments: "https://news.ycombinator.com/item?id=38246668",
      published: Time.zone.now,
      summary: "<a href=\"https://news.ycombinator.com/item?id=38246682\">Comments</a>",
      title: "Run LLMs on my own Mac fast and efficient",
      url: "https://www.secondstate.io/articles/fast-llm-inference",
      content: "",
      id: "test"
    }.merge(opts)
    double(entry)
  end

  def create_raw_feed(last_modified: Time.zone.now, entries: [])
    double(last_modified:, entries:)
  end

  context "when no new posts have been added" do
    it "does not add any new posts" do
      feed = build(:feed, last_fetched: Time.zone.local(2013, 1, 1))
      raw_feed = double(last_modified: Time.zone.local(2012, 12, 31))

      allow(Feed::FindNewStories).to receive(:call).and_return([])

      allow(described_class).to receive(:fetch_raw_feed).and_return(raw_feed)
      expect(FeedRepository).to receive(:set_status).with(:green, feed)

      expect { described_class.call(feed) }.not_to change(feed.stories, :count)
    end
  end

  context "when new posts have been added" do
    it "only adds posts that are new" do
      feed = create(:feed)
      opts = { published: Time.zone.local(2013, 1, 1) }
      raw_feed = create_raw_feed(entries: [create_entry, create_entry(opts:)])

      allow(described_class).to receive(:fetch_raw_feed).and_return(raw_feed)

      expect { described_class.call(feed) }.to change(feed.stories, :count).by(1)
    end

    it "updates the last fetched time for the feed" do
      feed = create(:feed, last_fetched: Time.zone.local(2013, 1, 1))
      raw_feed = create_raw_feed(last_modified: Time.zone.now)

      allow(described_class).to receive(:fetch_raw_feed).and_return(raw_feed)

      expect { described_class.call(feed) }
        .to change { feed.last_fetched }.to(raw_feed.last_modified)
    end
  end

  context "feed status" do
    it "sets the status to green if things are all good" do
      feed = create(:feed)
      raw_feed = create_raw_feed(last_modified: Time.zone.now)

      allow(described_class).to receive(:fetch_raw_feed).and_return(raw_feed)

      expect { described_class.call(feed) }
        .to change { feed.status }.to("green")
    end

    it "sets the status to red if things go wrong" do
      feed = create(:feed)
      allow(described_class).to receive(:fetch_raw_feed).and_return(404)

      expect { described_class.call(feed) }.to change { feed.status }.to("red")
    end

    it "outputs a message when things go wrong" do
      feed = create(:feed)
      allow(described_class).to receive(:fetch_raw_feed).and_return(404)

      expect { described_class.call(feed) }
        .to invoke(:error).on(Rails.logger).with(/Something went wrong/)
    end
  end
end
