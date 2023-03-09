# frozen_string_literal: true

require "support/feed_server"

RSpec.describe "Feed importing" do
  let(:server) { FeedServer.new }
  let(:feed) do
    create(
      :feed,
      name: "Example feed",
      last_fetched: Time.zone.local(2014, 1, 1),
      url: server.url
    )
  end

  describe "Valid feed" do
    before do
      # articles older than 3 days are ignored, so freeze time within
      # applicable range of the stories in the sample feed
      travel_to(Time.parse("2014-08-15T17:30:00Z"))
    end

    describe "Importing for the first time" do
      it "imports all entries" do
        server.response = sample_data("feeds/feed01_valid_feed/feed.xml")
        expect { FetchFeed.call(feed) }.to change(feed.stories, :count).to(5)
      end
    end

    describe "Importing for the second time" do
      before do
        server.response = sample_data("feeds/feed01_valid_feed/feed.xml")
        FetchFeed.call(feed)
      end

      context "no new entries" do
        it "does not create new stories" do
          server.response = sample_data("feeds/feed01_valid_feed/feed.xml")
          expect { FetchFeed.call(feed) }.not_to change(feed.stories, :count)
        end
      end

      context "new entries" do
        it "creates new stories" do
          server.response =
            sample_data("feeds/feed01_valid_feed/feed_updated.xml")
          expect { FetchFeed.call(feed) }.to change(feed.stories, :count).by(1)
        end
      end
    end
  end

  describe "Feed with incorrect pubdates" do
    before { travel_to(Time.parse("2014-08-12T17:30:00Z")) }

    context "has been fetched before" do
      it "imports all new stories" do
        # This spec describes a scenario where the feed is reporting incorrect
        # published dates for stories. The feed in question is
        # feeds.feedburner.com/GiantRobotsSmashingIntoOtherGiantRobots. When an
        # article is published the published date is always set to 00:00 of the
        # day the article was published. This specs shows that with the current
        # behaviour (08-15-2014) Stringer will not detect this article, if the
        # last time this feed was fetched is after 00:00 the day the article
        # was published.

        feed.last_fetched = Time.parse("2014-08-12T00:01:00Z")
        server.response =
          sample_data("feeds/feed02_invalid_published_dates/feed.xml")

        expect { FetchFeed.call(feed) }.to change { feed.stories.count }.by(1)
      end
    end
  end
end

def sample_data(path)
  File.new(File.join("spec", "sample_data", path)).read
end
