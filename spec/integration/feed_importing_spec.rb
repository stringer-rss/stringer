# frozen_string_literal: true

require "support/feed_server"

RSpec.describe "Feed importing" do
  def create_server(url: "feed01_valid_feed/feed.xml")
    server = FeedServer.new
    server.response = sample_data(url)
    server
  end

  def create_feed(**)
    create(
      :feed,
      name: "Example feed",
      last_fetched: Time.zone.local(2014, 1, 1),
      **
    )
  end

  describe "Valid feed" do
    # articles older than 3 days are ignored, so freeze time within
    # applicable range of the stories in the sample feed
    # travel_to(Time.parse("2014-08-15T17:30:00Z"))

    describe "Importing for the first time" do
      it "imports all entries" do
        travel_to(Time.parse("2014-08-15T17:30:00Z"))
        feed = create_feed(url: create_server.url)
        expect { Feed::FetchOne.call(feed) }
          .to change(feed.stories, :count).to(5)
      end
    end

    describe "Importing for the second time" do
      context "no new entries" do
        it "does not create new stories" do
          travel_to(Time.parse("2014-08-15T17:30:00Z"))
          feed = create_feed(url: create_server.url)
          Feed::FetchOne.call(feed)
          expect { Feed::FetchOne.call(feed) }
            .not_to change(feed.stories, :count)
        end
      end

      context "new entries" do
        it "creates new stories" do
          travel_to(Time.parse("2014-08-15T17:30:00Z"))
          server = create_server
          feed = create_feed(url: server.url)
          Feed::FetchOne.call(feed)
          server.response = sample_data("feed01_valid_feed/feed_updated.xml")
          expect { Feed::FetchOne.call(feed) }
            .to change(feed.stories, :count).by(1)
        end
      end
    end
  end

  describe "Feed with incorrect pubdates" do
    context "has been fetched before" do
      url = "feed02_invalid_published_dates/feed.xml"
      last_fetched = Time.parse("2014-08-12T00:01:00Z")

      it "imports all new stories" do
        # This spec describes a scenario where the feed is reporting incorrect
        # published dates for stories. The feed in question is
        # feeds.feedburner.com/GiantRobotsSmashingIntoOtherGiantRobots. When an
        # article is published the published date is always set to 00:00 of the
        # day the article was published. This specs shows that with the current
        # behaviour (08-15-2014) Stringer will not detect this article, if the
        # last time this feed was fetched is after 00:00 the day the article
        # was published.

        travel_to(Time.parse("2014-08-12T17:30:00Z"))
        server = create_server(url:)
        feed = create_feed(url: server.url, last_fetched:)

        expect { Feed::FetchOne.call(feed) }
          .to change(feed.stories, :count).by(1)
      end
    end
  end
end

def sample_data(path)
  File.new(File.join("spec", "sample_data", "feeds", path)).read
end
