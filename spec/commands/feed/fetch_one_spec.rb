# frozen_string_literal: true

RSpec.describe Feed::FetchOne do
  include ActiveSupport::Testing::TimeHelpers

  def create_entry(**options)
    entry = {
      published: Time.zone.now,
      title: "Run LLMs on my own Mac fast and efficient",
      url: "https://www.secondstate.io/articles/fast-llm-inference",
      content: "",
      id: "test",
      **options
    }
    double(entry)
  end

  def stub_raw_feed(feed, entries: [])
    xml = GenerateXml.call(feed, entries)
    stub_request(:get, feed.url).to_return(status: 200, body: xml)
  end

  context "when no new posts have been added" do
    it "does not add any new posts" do
      feed = create(:feed)
      stub_raw_feed(feed)

      expect { described_class.call(feed) }.not_to change(feed.stories, :count)
    end

    it "does not add posts that are old" do
      feed = create(:feed)
      entry = create_entry(published: Time.zone.local(2013, 1, 1))
      stub_raw_feed(feed, entries: [entry])

      expect { described_class.call(feed) }.not_to change(feed.stories, :count)
    end
  end

  context "when new posts have been added" do
    it "only adds posts that are new" do
      feed = create(:feed)
      stub_raw_feed(feed, entries: [create_entry])

      expect { described_class.call(feed) }
        .to change(feed.stories, :count).by(1)
    end

    it "updates the last fetched time for the feed" do
      feed = create(:feed, last_fetched: Time.zone.local(2013, 1, 1))
      freeze_time
      stub_raw_feed(feed, entries: [create_entry])

      expect { described_class.call(feed) }
        .to change(feed, :last_fetched).to(Time.zone.now)
    end
  end

  context "feed status" do
    it "sets the status to green if things are all good" do
      feed = create(:feed)
      stub_raw_feed(feed)

      expect { described_class.call(feed) }.to change(feed, :status).to("green")
    end

    it "sets the status to red if things go wrong" do
      feed = create(:feed)
      allow(described_class).to receive(:fetch_raw_feed).and_return(404)

      expect { described_class.call(feed) }.to change(feed, :status).to("red")
    end

    it "outputs a message when things go wrong" do
      feed = create(:feed)
      allow(described_class).to receive(:fetch_raw_feed).and_return(404)

      expect { described_class.call(feed) }
        .to invoke(:error).on(Rails.logger).with(/Something went wrong/)
    end
  end
end
