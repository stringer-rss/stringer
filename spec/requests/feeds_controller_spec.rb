# frozen_string_literal: true

RSpec.describe FeedsController do
  include ActiveJob::TestHelper

  describe "#index" do
    it "renders a list of feeds" do
      login_as(default_user)
      create_pair(:feed)

      get "/feeds"

      expect(rendered).to have_css("li.feed", count: 2)
    end

    it "displays message to add feeds if there are none" do
      login_as(default_user)

      get "/feeds"

      expect(rendered).to have_css("#add-some-feeds")
    end
  end

  describe "#show" do
    it "displays a list of stories" do
      login_as(default_user)
      story = create(:story)

      get "/feed/#{story.feed_id}"

      expect(rendered).to have_css("#stories")
    end

    it "raises an error if the feed belongs to another user" do
      login_as(create(:user))
      feed = create(:feed)

      expect { get("/feed/#{feed.id}") }
        .to raise_error(Authorization::NotAuthorizedError)
    end
  end

  describe "#edit" do
    it "displays the feed edit form" do
      login_as(default_user)
      feed = create(:feed, name: "Rainbows/unicorns", url: "http://example.com/feed")

      get "/feeds/#{feed.id}/edit"

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
      feed = create(:feed, url: "http://example.com/atom", id: "12")

      feed_url = "http://example.com/feed"

      expect { put("/feeds/#{feed.id}", params: params(feed, feed_url:)) }
        .to change_record(feed, :url).to(feed_url)
    end

    it "updates a feed group given the id" do
      login_as(default_user)
      feed = create(:feed, url: "http://example.com/atom")

      expect { put("/feeds/#{feed.id}", params: params(feed, group_id: 321)) }
        .to change_record(feed, :group_id).to(321)
    end

    it "does not store a url with a disallowed scheme" do
      login_as(default_user)
      feed = create(:feed, url: "http://example.com/atom")
      feed_url = "javascript:alert(document.domain)"

      expect { put("/feeds/#{feed.id}", params: params(feed, feed_url:)) }
        .not_to change_record(feed, :url)
    end

    it "reports the failure instead of claiming success" do
      login_as(default_user)
      feed = create(:feed, url: "http://example.com/atom")
      feed_url = "javascript:alert(document.domain)"

      put("/feeds/#{feed.id}", params: params(feed, feed_url:))

      expect(rendered).to have_css(".error")
    end
  end

  describe "#destroy" do
    it "deletes a feed given the id" do
      login_as(default_user)
      feed = create(:feed)

      expect { delete("/feeds/#{feed.id}") }.to delete_record(feed)
    end
  end

  describe "#new" do
    it "displays a new feed form" do
      login_as(default_user)

      get "/feeds/new"

      expect(rendered).to have_css("form#add-feed-setup")
    end
  end

  def with_test_adapter
    adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test

    yield

    ActiveJob::Base.queue_adapter = adapter
  end

  describe "#create" do
    context "when the feed url is valid" do
      feed_url = "http://example.com/"

      around { |example| with_test_adapter(&example) }

      it "adds the feed and queues it to be fetched" do
        login_as(default_user)
        stub_request(:get, feed_url).to_return(status: 200, body: "<rss></rss>")

        expect { post("/feeds", params: { feed_url: }) }
          .to change(Feed, :count).by(1)
      end

      it "queues the feed to be fetched" do
        login_as(default_user)
        stub_request(:get, feed_url).to_return(status: 200, body: "<rss></rss>")

        expect { post("/feeds", params: { feed_url: }) }
          .to enqueue_job(CallableJob).with(Feed::FetchOne, instance_of(Feed))
      end
    end

    context "when the feed url is invalid" do
      feed_url = "http://not-a-valid-feed.com/"

      it "does not add the feed" do
        login_as(default_user)
        stub_request(:get, feed_url).to_return(status: 404)
        post("/feeds", params: { feed_url: })

        expect(rendered).to have_css(".error")
      end
    end

    context "when the feed document declares a disallowed self url" do
      feed_url = "http://example.com/"
      hostile_atom = <<~XML
        <?xml version="1.0" encoding="utf-8"?>
        <feed xmlns="http://www.w3.org/2005/Atom">
          <title>Hostile</title>
          <link rel="self" href="javascript:alert(document.domain)"/>
        </feed>
      XML

      it "does not add the feed" do
        login_as(default_user)
        stub_request(:get, feed_url).to_return(status: 200, body: hostile_atom)

        expect { post("/feeds", params: { feed_url: }) }
          .not_to change(Feed, :count)
      end

      it "explains the real reason rather than 'already subscribed'" do
        login_as(default_user)
        stub_request(:get, feed_url).to_return(status: 200, body: hostile_atom)

        post("/feeds", params: { feed_url: })

        expect(rendered)
          .to have_css(".error", text: "must be an http or https address")
      end
    end

    context "when the feed url is one we already subscribe to" do
      feed_url = "http://example.com/"

      it "does not add the feed" do
        login_as(default_user)
        create(:feed, url: feed_url)
        stub_request(:get, feed_url).to_return(status: 200, body: "<rss></rss>")

        post("/feeds", params: { feed_url: })

        expect(rendered).to have_css(".error")
      end
    end
  end
end
