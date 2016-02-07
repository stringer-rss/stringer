require "spec_helper"

app_require "controllers/feeds_controller"

describe "FeedsController" do
  let(:feeds) { [FeedFactory.build, FeedFactory.build] }

  describe "GET /feeds" do
    it "renders a list of feeds" do
      expect(FeedRepository).to receive(:list).and_return(feeds)

      get "/feeds"

      page = last_response.body
      expect(page).to have_tag("ul#feed-list")
      expect(page).to have_tag("li.feed", count: 2)
    end

    it "displays message to add feeds if there are none" do
      expect(FeedRepository).to receive(:list).and_return([])

      get "/feeds"

      page = last_response.body
      expect(page).to have_tag("#add-some-feeds")
    end
  end

  describe "GET /feeds/:feed_id/edit" do
    it "fetches a feed given the id" do
      feed = Feed.new(name: "Rainbows and unicorns", url: "example.com/feed")
      expect(FeedRepository).to receive(:fetch).with("123").and_return(feed)

      get "/feeds/123/edit"

      expect(last_response.body).to include("Rainbows and unicorns")
      expect(last_response.body).to include("example.com/feed")
    end
  end

  describe "PUT /feeds/:feed_id" do
    it "updates a feed given the id" do
      feed = FeedFactory.build(url: "example.com/atom")
      expect(FeedRepository).to receive(:fetch).with("123").and_return(feed)
      expect(FeedRepository).to receive(:update_feed).with(feed, "Test", "example.com/feed", nil)

      put "/feeds/123", feed_id: "123", feed_name: "Test", feed_url: "example.com/feed"

      expect(last_response).to be_redirect
    end

    it "updates a feed group given the id" do
      feed = FeedFactory.build(url: "example.com/atom")
      expect(FeedRepository).to receive(:fetch).with("123").and_return(feed)
      expect(FeedRepository).to receive(:update_feed).with(feed, feed.name, feed.url, "321")

      put "/feeds/123", feed_id: "123", feed_name: feed.name, feed_url: feed.url, group_id: "321"

      expect(last_response).to be_redirect
    end
  end

  describe "DELETE /feeds/:feed_id" do
    it "deletes a feed given the id" do
      expect(FeedRepository).to receive(:delete).with("123")

      delete "/feeds/123"
    end
  end

  describe "GET /feeds/new" do
    it "displays a form and submit button" do
      get "/feeds/new"

      page = last_response.body
      expect(page).to have_tag("form#add-feed-setup")
      expect(page).to have_tag("input#submit")
    end
  end

  describe "POST /feeds" do
    context "when the feed url is valid" do
      let(:feed_url) { "http://example.com/" }
      let(:valid_feed) { double(valid?: true) }

      it "adds the feed and queues it to be fetched" do
        expect(AddNewFeed).to receive(:add).with(feed_url).and_return(valid_feed)
        expect(FetchFeeds).to receive(:enqueue).with([valid_feed])

        post "/feeds", feed_url: feed_url

        expect(last_response.status).to be 302
        expect(URI.parse(last_response.location).path).to eq "/"
      end
    end

    context "when the feed url is invalid" do
      let(:feed_url) { "http://not-a-valid-feed.com/" }

      it "adds the feed and queues it to be fetched" do
        expect(AddNewFeed).to receive(:add).with(feed_url).and_return(false)

        post "/feeds", feed_url: feed_url

        page = last_response.body
        expect(page).to have_tag(".error")
      end
    end

    context "when the feed url is one we already subscribe to" do
      let(:feed_url) { "http://example.com/" }
      let(:invalid_feed) { double(valid?: false) }

      it "adds the feed and queues it to be fetched" do
        expect(AddNewFeed).to receive(:add).with(feed_url).and_return(invalid_feed)

        post "/feeds", feed_url: feed_url

        page = last_response.body
        expect(page).to have_tag(".error")
      end
    end
  end

  describe "GET /feeds/import" do
    it "displays the import options" do
      get "/feeds/import"

      page = last_response.body
      expect(page).to have_tag("input#opml_file")
      expect(page).to have_tag("a#skip")
    end
  end

  describe "POST /feeds/import" do
    let(:opml_file) { Rack::Test::UploadedFile.new("spec/sample_data/subscriptions.xml", "application/xml") }

    it "parse OPML and starts fetching" do
      expect(ImportFromOpml).to receive(:import).once

      post "/feeds/import", "opml_file" => opml_file

      expect(last_response.status).to be 302
      expect(URI.parse(last_response.location).path).to eq "/setup/tutorial"
    end
  end

  describe "GET /feeds/export" do
    let(:some_xml) { "<xml>some dummy opml</xml>" }
    before { allow(Feed).to receive(:all) }

    it "returns an OPML file" do
      expect_any_instance_of(ExportToOpml).to receive(:to_xml).and_return(some_xml)

      get "/feeds/export"

      expect(last_response.body).to eq some_xml
      expect(last_response.header["Content-Type"]).to include "application/xml"
      expect(last_response.header["Content-Disposition"]).to eq("attachment; filename=\"stringer.opml\"")
    end
  end
end
