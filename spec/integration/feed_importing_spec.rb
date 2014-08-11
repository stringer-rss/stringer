require "spec_helper"
require "support/active_record"
require "support/feed_server"
require "capybara"
require "capybara/server"

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
    describe "Importing for the first time" do
      it "imports all entries" do
        @server.response = sample_data('feeds/feed01_valid_feed/feed.xml')
        expect { fetch_feed(feed) }.to change{ feed.stories.count }.to(5)
      end
    end

    describe "Importing for the second time" do
      before(:each) do
        @server.response = sample_data('feeds/feed01_valid_feed/feed.xml')
        fetch_feed(feed)
      end

      context "no new entries" do
        it "does not create new stories" do
          @server.response = sample_data('feeds/feed01_valid_feed/feed.xml')
          expect { fetch_feed(feed) }.to_not change{ feed.stories.count }
        end
      end

      context "new entries" do
        it "creates new stories" do
          @server.response = sample_data('feeds/feed01_valid_feed/feed_updated.xml')
          expect { fetch_feed(feed) }.to change{ feed.stories.count }.by(1).to(6)
        end
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
