# frozen_string_literal: true

RSpec.describe FetchFeed do
  describe "#fetch" do
    let(:daring_fireball) do
      double(
        id: 1,
        url: "http://daringfireball.com/feed",
        last_fetched: Time.zone.local(2013, 1, 1),
        stories: []
      )
    end

    before do
      allow(StoryRepository).to receive(:add)
      allow(FeedRepository).to receive(:update_last_fetched)
      allow(FeedRepository).to receive(:set_status)

      stub_request(:get, "http://daringfireball.com/feed")
    end

    context "when feed has not been modified" do
      it "does not try to fetch posts" do
        expect(Feedjira).to receive(:parse).and_return(304)

        expect(StoryRepository).not_to receive(:add)

        described_class.new(daring_fireball, logger: nil).fetch
      end

      it "logs a message" do
        expect(Feedjira).to receive(:parse).and_return(304)
        output = StringIO.new
        logger = Logger.new(output)

        described_class.new(daring_fireball, logger:).fetch

        expect(output.string).to include("has not been modified")
      end
    end

    context "when no new posts have been added" do
      it "does not add any new posts" do
        fake_feed = double(last_modified: Time.zone.local(2012, 12, 31))
        expect(Feedjira).to receive(:parse).and_return(fake_feed)

        allow(FindNewStories).to receive(:call).and_return([])

        expect(StoryRepository).not_to receive(:add)

        described_class.new(daring_fireball).fetch
      end
    end

    context "when new posts have been added" do
      let(:now) { Time.zone.now }
      let(:new_story) { double }
      let(:old_story) { double }

      let(:fake_feed) do
        double(last_modified: now, entries: [new_story, old_story])
      end

      before do
        allow(FindNewStories).to receive(:call).and_return([new_story])
      end

      it "only adds posts that are new" do
        expect(Feedjira).to receive(:parse).and_return(fake_feed)
        expect(StoryRepository).to receive(:add).with(
          new_story,
          daring_fireball
        )
        expect(StoryRepository)
          .not_to receive(:add).with(old_story, daring_fireball)

        described_class.new(daring_fireball).fetch
      end

      it "updates the last fetched time for the feed" do
        expect(Feedjira).to receive(:parse).and_return(fake_feed)
        expect(FeedRepository).to receive(:update_last_fetched)
          .with(daring_fireball, now)

        described_class.new(daring_fireball).fetch
      end
    end

    context "feed status" do
      it "sets the status to green if things are all good" do
        fake_feed =
          double(last_modified: Time.zone.local(2012, 12, 31), entries: [])
        expect(Feedjira).to receive(:parse).and_return(fake_feed)

        expect(FeedRepository).to receive(:set_status)
          .with(:green, daring_fireball)

        described_class.new(daring_fireball).fetch
      end

      it "sets the status to red if things go wrong" do
        expect(Feedjira).to receive(:parse).and_return(404)

        expect(FeedRepository).to receive(:set_status)
          .with(:red, daring_fireball)

        described_class.new(daring_fireball, logger: nil).fetch
      end

      it "outputs a message when things go wrong" do
        expect(Feedjira).to receive(:parse).and_return(404)
        output = StringIO.new
        logger = Logger.new(output)

        described_class.new(daring_fireball, logger:).fetch

        expect(output.string).to include("Something went wrong")
      end
    end
  end
end
