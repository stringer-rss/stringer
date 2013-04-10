require "spec_helper"
app_require "tasks/fetch_feed"

class Feed < OpenStruct; end;

describe FetchFeed do
  let (:daring_fireball) {
    Feed.new(name: "Daring Fireball", url: "http://daringfireball.net/index.xml", last_fetched: Time.new(2013, 4, 5))
  }

  describe "#fetch" do
    it "fetches the feed" do
      result = FetchFeed.new(daring_fireball).fetch
      result.title.should eq "Daring Fireball"
      result.entries.first.author.should eq "John Gruber"
    end

    context "when no new posts have been added" do
      it "should not add any new posts" do
        fake_feed = stub(last_modified: Time.new(2012, 12, 31))
        parser = stub(fetch_and_parse: fake_feed)

        StoryRepository.should_not_receive(:add)

        FetchFeed.new(daring_fireball, parser).fetch
      end
    end

    context "when new posts have been added" do
      let(:now) { Time.now }
      let(:new_story){ stub(published: now + 1) }
      let(:old_story) { stub(published: Time.new(2009, 4, 20)) }

      let(:fake_feed) { stub(last_modified: now, entries: [new_story, old_story]) }
      let(:fake_parser) { stub(fetch_and_parse: fake_feed) }

      it "should only add posts that are new" do
        StoryRepository.should_receive(:add).with(new_story, daring_fireball)
        StoryRepository.should_not_receive(:add).with(old_story, daring_fireball)

        FetchFeed.new(daring_fireball, fake_parser).fetch
      end

      it "should update the last fetched time for the feed" do
        FeedRepository.should_receive(:update_last_fetched)
          .with(daring_fireball, now)

        FetchFeed.new(daring_fireball, fake_parser).fetch
      end
    end
  end
end