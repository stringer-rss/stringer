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

    it "titles the page with the page name and site name" do
      login_as(default_user)

      get "/feeds"

      expect(rendered).to have_title("Feeds | stringer", exact: true)
    end

    it "displays message to add feeds if there are none" do
      login_as(default_user)

      get "/feeds"

      expect(rendered).to have_css("#add-some-feeds")
    end

    it "displays the unread count for feeds with unread stories" do
      login_as(default_user)
      feed = create(:feed, name: "Unicorns")
      create(:story, feed:)

      get "/feeds"

      expect(rendered).to have_link("(1) Unicorns")
    end

    it "displays the feed status" do
      login_as(default_user)
      create(:feed, status: :green)

      get "/feeds"

      expect(rendered).to have_css(".sr-only", text: "Success!")
    end

    it "displays when the feed was last fetched" do
      login_as(default_user)
      create(:feed, last_fetched: Time.zone.local(2026, 1, 2, 3, 4))

      get "/feeds"

      expect(rendered).to have_css(".last-updated-time", text: "Jan 02, 03:04")
    end
  end

  describe "#show" do
    it "displays a list of stories" do
      login_as(default_user)
      story = create(:story)

      get "/feed/#{story.feed_id}"

      expect(rendered).to have_css("#stories")
    end

    it "shows the unread count in the page title" do
      login_as(default_user)
      story = create(:story)

      get "/feed/#{story.feed_id}"

      expect(rendered).to have_title("(1) #{story.feed.name} | stringer")
    end

    it "leaves the unread count out of the title when all stories are read" do
      login_as(default_user)
      story = create(:story, :read)

      get "/feed/#{story.feed_id}"

      title = "#{story.feed.name} | stringer"
      expect(rendered).to have_title(title, exact: true)
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

    it "displays a group select with the feed's group selected" do
      login_as(default_user)
      feed = create(:feed, :with_group)

      get "/feeds/#{feed.id}/edit"

      expect(rendered).to have_select("group_id", selected: feed.group.name)
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

    it "shows a success message on the feeds page" do
      login_as(default_user)
      feed = create(:feed)

      delete("/feeds/#{feed.id}")
      follow_redirect!

      expect(rendered).to have_css(".alert-success", text: "Feed deleted.")
    end
  end

  describe "#new" do
    it "displays a new feed form" do
      login_as(default_user)

      get "/feeds/new"

      expect(rendered).to have_css("form#add-feed-setup")
    end
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
