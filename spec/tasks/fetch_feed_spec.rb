require "spec_helper"
app_require "tasks/fetch_feed"

describe FetchFeed do
  describe "#fetch" do
    let(:daring_fireball) do
      double(id: 1,
             url: "http://daringfireball.com/feed",
             last_fetched: Time.new(2013, 1, 1),
             stories: [])
    end

    before do
      allow(StoryRepository).to receive(:add)
      allow(FeedRepository).to receive(:update_last_fetched)
      allow(FeedRepository).to receive(:set_status)
    end

    context "when feed has not been modified" do
      it "should not try to fetch posts" do
        parser = double(fetch_and_parse: 304)

        expect(StoryRepository).not_to receive(:add)

        FetchFeed.new(daring_fireball, parser: parser)
      end
    end

    context "when no new posts have been added" do
      it "should not add any new posts" do
        fake_feed = double(last_modified: Time.new(2012, 12, 31))
        parser = double(fetch_and_parse: fake_feed)

        allow_any_instance_of(FindNewStories).to receive(:new_stories).and_return([])

        expect(StoryRepository).not_to receive(:add)

        FetchFeed.new(daring_fireball, parser: parser).fetch
      end
    end

    context "when new posts have been added" do
      let(:now) { Time.now }
      let(:new_story) { double }
      let(:old_story) { double }

      let(:fake_feed) { double(last_modified: now, entries: [new_story, old_story]) }
      let(:fake_parser) { double(fetch_and_parse: fake_feed) }

      before { allow_any_instance_of(FindNewStories).to receive(:new_stories).and_return([new_story]) }

      it "should only add posts that are new" do
        expect(StoryRepository).to receive(:add).with(new_story, daring_fireball)
        expect(StoryRepository).not_to receive(:add).with(old_story, daring_fireball)

        FetchFeed.new(daring_fireball, parser: fake_parser).fetch
      end

      it "should update the last fetched time for the feed" do
        expect(FeedRepository).to receive(:update_last_fetched)
          .with(daring_fireball, now)

        FetchFeed.new(daring_fireball, parser: fake_parser).fetch
      end
    end

    context "feed status" do
      it "sets the status to green if things are all good" do
        fake_feed = double(last_modified: Time.new(2012, 12, 31), entries: [])
        parser = double(fetch_and_parse: fake_feed)

        expect(FeedRepository).to receive(:set_status)
          .with(:green, daring_fireball)

        FetchFeed.new(daring_fireball, parser: parser).fetch
      end

      it "sets the status to red if things go wrong" do
        parser = double(fetch_and_parse: 404)

        expect(FeedRepository).to receive(:set_status)
          .with(:red, daring_fireball)

        FetchFeed.new(daring_fireball, parser: parser).fetch
      end
    end
  end
end
