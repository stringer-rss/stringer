require "spec_helper"

app_require "controllers/feeds_controller"

describe "FeedsController" do
  let(:feeds) { [FeedFactory.build, FeedFactory.build] }

  describe "GET /feeds" do
    it "renders a list of feeds" do
      FeedRepository.should_receive(:list).and_return(feeds)

      get "/feeds"

      page = last_response.body
      page.should have_tag("ul#feed-list")
      page.should have_tag("li.feed", count: 2)
    end

    it "displays message to add feeds if there are none" do
      FeedRepository.should_receive(:list).and_return([])

      get "/feeds"

      page = last_response.body
      page.should have_tag("#add-some-feeds")
    end
  end

  describe "GET /feeds/:feed_id/edit" do
    it "fetches a feed given the id" do
      feed = Feed.new(name: 'Rainbows and unicorns', url: 'example.com/feed')
      FeedRepository.should_receive(:fetch).with("123").and_return(feed)

      get "/feeds/123/edit"

      last_response.body.should include('Rainbows and unicorns')
      last_response.body.should include('example.com/feed')
    end
  end

  describe "PUT /feeds/:feed_id" do
    it "updates a feed given the id" do
      feed = FeedFactory.build(url: 'example.com/atom')
      FeedRepository.should_receive(:fetch).with("123").and_return(feed)
      FeedRepository.should_receive(:update_feed).with(feed, 'Test', 'example.com/feed')

      put "/feeds/123", feed_id: "123", feed_name: "Test", feed_url: "example.com/feed"

      last_response.should be_redirect
    end
  end

  describe "DELETE /feeds/:feed_id" do
    it "deletes a feed given the id" do
      FeedRepository.should_receive(:delete).with("123")

      delete "/feeds/123"
    end
  end

  describe "GET /feeds/new" do
    it "displays a form and submit button" do
      get "/feeds/new"

      page = last_response.body
      page.should have_tag("form#add-feed-setup")
      page.should have_tag("input#submit")
    end
  end

  describe "POST /feeds" do
    context "when the feed url is valid" do
      let(:feed_url) { "http://example.com/" }
      let(:valid_feed) { double(valid?: true) }

      it "adds the feed and queues it to be fetched" do
        AddNewFeed.should_receive(:add).with(feed_url).and_return(valid_feed)
        FetchFeeds.should_receive(:enqueue).with([valid_feed])

        post "/feeds", feed_url: feed_url

        last_response.status.should be 302
        URI::parse(last_response.location).path.should eq "/"
      end
    end

    context "when the feed url is invalid" do
      let(:feed_url) { "http://not-a-valid-feed.com/" }

      it "adds the feed and queues it to be fetched" do
        AddNewFeed.should_receive(:add).with(feed_url).and_return(false)

        post "/feeds", feed_url: feed_url

        page = last_response.body
        page.should have_tag(".error")
      end
    end

    context "when the feed url is one we already subscribe to" do
      let(:feed_url) { "http://example.com/" }
      let(:invalid_feed) { double(valid?: false) }

      it "adds the feed and queues it to be fetched" do
        AddNewFeed.should_receive(:add).with(feed_url).and_return(invalid_feed)

        post "/feeds", feed_url: feed_url

        page = last_response.body
        page.should have_tag(".error")
      end
    end
  end

  describe "GET /feeds/import" do
    it "displays the import options" do
      get "/feeds/import"

      page = last_response.body
      page.should have_tag("input#opml_file")
      page.should have_tag("a#skip")
    end
  end

  describe "POST /feeds/import" do
    let(:opml_file) { Rack::Test::UploadedFile.new("spec/sample_data/subscriptions.xml", "application/xml") }

    it "parse OPML and starts fetching" do
      ImportFromOpml.should_receive(:import).once

      post "/feeds/import", {"opml_file" => opml_file}

      last_response.status.should be 302
      URI::parse(last_response.location).path.should eq "/setup/tutorial"
    end
  end

  describe "GET /feeds/export" do
    let(:some_xml) { "<xml>some dummy opml</xml>"}
    before { Feed.stub(:all) }

    it "returns an OPML file" do
      ExportToOpml.any_instance.should_receive(:to_xml).and_return(some_xml)

      get "/feeds/export"

      last_response.body.should eq some_xml
      last_response.header["Content-Type"].should include 'application/xml'
      last_response.header["Content-Disposition"].should == "attachment; filename=\"stringer.opml\""
    end
  end
end
