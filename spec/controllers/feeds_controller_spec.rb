# frozen_string_literal: true

require "spec_helper"

app_require "controllers/feeds_controller"

describe FeedsController do
  describe "#index" do
    it "renders a list of feeds" do
      create_pair(:feed)

      get "/feeds"

      rendered = Capybara.string(last_response.body)
      expect(rendered).to have_selector("li.feed", count: 2)
    end

    it "displays message to add feeds if there are none" do
      get "/feeds"

      page = last_response.body
      expect(page).to have_tag("#add-some-feeds")
    end
  end

  describe "#show" do
    it "displays a list of stories" do
      story = create(:story)
      get "/feed/#{story.feed_id}"

      expect(last_response.body).to have_tag("#stories")
    end
  end

  describe "#edit" do
    it "displays the feed edit form" do
      feed = create(:feed, name: "Rainbows/unicorns", url: "example.com/feed")

      get "/feeds/#{feed.id}/edit"

      rendered = Capybara.string(last_response.body)
      expect(rendered).to have_field("feed_name", with: "Rainbows/unicorns")
    end
  end

  def mock_feed(feed, name, url, group_id = nil)
    expect(FeedRepository).to receive(:fetch).with("123").and_return(feed)
    expect(FeedRepository).to receive(:update_feed).with(
      feed,
      name,
      url,
      group_id
    )
  end

  describe "#update" do
    def params(feed, **overrides)
      {
        feed_id: feed.id,
        feed_name: feed.name,
        feed_url: feed.url,
        group_id: feed.group_id,
        **overrides
      }
    end

    it "updates a feed given the id" do
      feed = build(:feed, url: "example.com/atom", id: "12", group_id: nil)
      mock_feed(feed, "Test", "example.com/feed")

      feed_url = "example.com/feed"
      put "/feeds/123", **params(feed, feed_name: "Test", feed_url:)

      expect(last_response).to be_redirect
    end

    it "updates a feed group given the id" do
      feed = build(:feed, url: "example.com/atom")
      mock_feed(feed, feed.name, feed.url, "321")

      put "/feeds/123", **params(feed, feed_id: "123", group_id: "321")

      expect(last_response).to be_redirect
    end
  end

  describe "#destroy" do
    it "deletes a feed given the id" do
      expect(FeedRepository).to receive(:delete).with("123")

      delete "/feeds/123"
    end
  end

  describe "#new" do
    it "displays a new feed form" do
      get "/feeds/new"

      page = last_response.body
      expect(page).to have_tag("form#add-feed-setup")
    end
  end

  describe "#create" do
    context "when the feed url is valid" do
      let(:feed_url) { "http://example.com/" }

      it "adds the feed and queues it to be fetched" do
        stub_request(:get, feed_url).to_return(status: 200, body: "<rss></rss>")

        expect { post("/feeds", feed_url:) }.to change(Feed, :count).by(1)
      end

      it "queues the feed to be fetched" do
        stub_request(:get, feed_url).to_return(status: 200, body: "<rss></rss>")
        expect(FetchFeeds).to receive(:enqueue).with([instance_of(Feed)])

        post("/feeds", feed_url:)
      end
    end

    context "when the feed url is invalid" do
      let(:feed_url) { "http://not-a-valid-feed.com/" }

      it "does not add the feed" do
        stub_request(:get, feed_url).to_return(status: 404)
        post("/feeds", feed_url:)

        page = last_response.body
        expect(page).to have_tag(".error")
      end
    end

    context "when the feed url is one we already subscribe to" do
      let(:feed_url) { "http://example.com/" }

      it "does not add the feed" do
        create(:feed, url: feed_url)
        stub_request(:get, feed_url).to_return(status: 200, body: "<rss></rss>")

        post("/feeds", feed_url:)

        page = last_response.body
        expect(page).to have_tag(".error")
      end
    end
  end
end
