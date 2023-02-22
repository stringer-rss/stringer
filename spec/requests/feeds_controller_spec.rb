# frozen_string_literal: true

RSpec.describe FeedsController, type: :request do
  describe "#index" do
    it "renders a list of feeds" do
      login_as(default_user)
      create_pair(:feed)

      get "/feeds"

      rendered = Capybara.string(response.body)
      expect(rendered).to have_selector("li.feed", count: 2)
    end

    it "displays message to add feeds if there are none" do
      login_as(default_user)

      get "/feeds"

      page = response.body
      expect(page).to have_tag("#add-some-feeds")
    end
  end

  describe "#show" do
    it "displays a list of stories" do
      login_as(default_user)
      story = create(:story)

      get "/feed/#{story.feed_id}"

      expect(response.body).to have_tag("#stories")
    end
  end

  describe "#edit" do
    it "displays the feed edit form" do
      login_as(default_user)
      feed = create(:feed, name: "Rainbows/unicorns", url: "example.com/feed")

      get "/feeds/#{feed.id}/edit"

      rendered = Capybara.string(response.body)
      expect(rendered).to have_field("feed_name", with: "Rainbows/unicorns")
    end
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
      login_as(default_user)
      feed = create(:feed, url: "example.com/atom", id: "12", group_id: nil)

      feed_url = "example.com/feed"
      put "/feeds/#{feed.id}", params: params(feed, feed_url:)

      expect(feed.reload.url).to eq(feed_url)
    end

    it "updates a feed group given the id" do
      login_as(default_user)
      feed = create(:feed, url: "example.com/atom")

      put "/feeds/#{feed.id}", params: params(feed, group_id: 321)

      expect(feed.reload.group_id).to eq(321)
    end
  end

  describe "#destroy" do
    it "deletes a feed given the id" do
      login_as(default_user)
      expect(FeedRepository).to receive(:delete).with("123")

      delete "/feeds/123"
    end
  end

  describe "#new" do
    it "displays a new feed form" do
      login_as(default_user)

      get "/feeds/new"

      page = response.body
      expect(page).to have_tag("form#add-feed-setup")
    end
  end

  describe "#create" do
    context "when the feed url is valid" do
      let(:feed_url) { "http://example.com/" }

      it "adds the feed and queues it to be fetched" do
        login_as(default_user)
        stub_request(:get, feed_url).to_return(status: 200, body: "<rss></rss>")

        expect { post("/feeds", params: { feed_url: }) }
          .to change(Feed, :count).by(1)
      end

      it "queues the feed to be fetched" do
        login_as(default_user)
        stub_request(:get, feed_url).to_return(status: 200, body: "<rss></rss>")
        expect(FetchFeeds).to receive(:enqueue).with([instance_of(Feed)])

        post("/feeds", params: { feed_url: })
      end
    end

    context "when the feed url is invalid" do
      let(:feed_url) { "http://not-a-valid-feed.com/" }

      it "does not add the feed" do
        login_as(default_user)
        stub_request(:get, feed_url).to_return(status: 404)
        post("/feeds", params: { feed_url: })

        page = response.body
        expect(page).to have_tag(".error")
      end
    end

    context "when the feed url is one we already subscribe to" do
      let(:feed_url) { "http://example.com/" }

      it "does not add the feed" do
        login_as(default_user)
        create(:feed, url: feed_url)
        stub_request(:get, feed_url).to_return(status: 200, body: "<rss></rss>")

        post("/feeds", params: { feed_url: })

        expect(response.body).to have_tag(".error")
      end
    end
  end
end
