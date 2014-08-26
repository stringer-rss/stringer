require "spec_helper"
require "time"
require "support/active_record"
require "support/feed_server"
require "capybara"
require "capybara/server"
require "timecop"

app_require "tasks/fetch_feed"

describe "Feed importing" do
  before(:all) do
    @server = FeedServer.new
  end

  let(:feed) do
    Feed.create(
      name: "Example feed",
      last_fetched: Time.new(2014, 1, 1),
      url: @server.url
    )
  end

  describe "Valid feed" do
    before(:all) do
      # articles older than 3 days are ignored, so freeze time within
      # applicable range of the stories in the sample feed
      Timecop.freeze Time.parse("2014-08-15T17:30:00Z")
    end

    describe "Importing for the first time" do
      it "imports all entries" do
        @server.response = sample_data("feeds/feed01_valid_feed/feed.xml")
        expect { fetch_feed(feed) }.to change{ feed.stories.count }.to(5)
      end
    end

    describe "Importing for the second time" do
      before(:each) do
        @server.response = sample_data("feeds/feed01_valid_feed/feed.xml")
        fetch_feed(feed)
      end

      context "no new entries" do
        it "does not create new stories" do
          @server.response = sample_data("feeds/feed01_valid_feed/feed.xml")
          expect { fetch_feed(feed) }.to_not change{ feed.stories.count }
        end
      end

      context "new entries" do
        it "creates new stories" do
          @server.response = sample_data("feeds/feed01_valid_feed/feed_updated.xml")
          expect { fetch_feed(feed) }.to change{ feed.stories.count }.by(1).to(6)
        end
      end
    end
  end

  describe "Feed with incorrect pubdates" do
    before(:all) do
      Timecop.freeze Time.parse("2014-08-12T17:30:00Z")
    end

    context "has been fetched before" do
      it "imports all new stories" do
        # This spec describes a scenario where the feed is reporting incorrect
        # published dates for stories.
        # The feed in question is feeds.feedburner.com/GiantRobotsSmashingIntoOtherGiantRobots.
        # When an article is published the published date is always set to 00:00 of
        # the day the article was published.
        # This specs shows that with the current behaviour (08-15-2014) Stringer
        # will not detect this article, if the last time this feed was fetched is
        # after 00:00 the day the article was published.

        feed.last_fetched = Time.parse("2014-08-12T00:01:00Z")
        @server.response = sample_data("feeds/feed02_invalid_published_dates/feed.xml")

        expect { fetch_feed(feed) }.to change{ feed.stories.count }.by(1)
      end
    end
  end
end

def sample_data(path)
  File.new(File.join("spec", "sample_data", path)).read
end

def fetch_feed(feed)
  logger = Logger.new(STDOUT)
  logger.level = Logger::DEBUG

  FetchFeed.new(feed, logger: logger).fetch
end
